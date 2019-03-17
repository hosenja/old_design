#!/bin/sh
set -e

echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

SWIFT_STDLIB_PATH="${DT_TOOLCHAIN_DIR}/usr/lib/swift/${PLATFORM_NAME}"

# Used as a return value for each invocation of `strip_invalid_archs` function.
STRIP_BINARY_RETVAL=0

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

# Copies and strips a vendored framework
install_framework()
{
  if [ -r "${BUILT_PRODUCTS_DIR}/$1" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$1"
  elif [ -r "${BUILT_PRODUCTS_DIR}/$(basename "$1")" ]; then
    local source="${BUILT_PRODUCTS_DIR}/$(basename "$1")"
  elif [ -r "$1" ]; then
    local source="$1"
  fi

  local destination="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"

  if [ -L "${source}" ]; then
      echo "Symlinked..."
      source="$(readlink "${source}")"
  fi

  # Use filter instead of exclude so missing patterns don't throw errors.
  echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${destination}\""
  rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${destination}"

  local basename
  basename="$(basename -s .framework "$1")"
  binary="${destination}/${basename}.framework/${basename}"
  if ! [ -r "$binary" ]; then
    binary="${destination}/${basename}"
  fi

  # Strip invalid architectures so "fat" simulator / device frameworks work on device
  if [[ "$(file "$binary")" == *"dynamically linked shared library"* ]]; then
    strip_invalid_archs "$binary"
  fi

  # Resign the code if required by the build settings to avoid unstable apps
  code_sign_if_enabled "${destination}/$(basename "$1")"

  # Embed linked Swift runtime libraries. No longer necessary as of Xcode 7.
  if [ "${XCODE_VERSION_MAJOR}" -lt 7 ]; then
    local swift_runtime_libs
    swift_runtime_libs=$(xcrun otool -LX "$binary" | grep --color=never @rpath/libswift | sed -E s/@rpath\\/\(.+dylib\).*/\\1/g | uniq -u  && exit ${PIPESTATUS[0]})
    for lib in $swift_runtime_libs; do
      echo "rsync -auv \"${SWIFT_STDLIB_PATH}/${lib}\" \"${destination}\""
      rsync -auv "${SWIFT_STDLIB_PATH}/${lib}" "${destination}"
      code_sign_if_enabled "${destination}/${lib}"
    done
  fi
}

# Copies and strips a vendored dSYM
install_dsym() {
  local source="$1"
  if [ -r "$source" ]; then
    # Copy the dSYM into a the targets temp dir.
    echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${source}\" \"${DERIVED_FILES_DIR}\""
    rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${source}" "${DERIVED_FILES_DIR}"

    local basename
    basename="$(basename -s .framework.dSYM "$source")"
    binary="${DERIVED_FILES_DIR}/${basename}.framework.dSYM/Contents/Resources/DWARF/${basename}"

    # Strip invalid architectures so "fat" simulator / device frameworks work on device
    if [[ "$(file "$binary")" == *"Mach-O dSYM companion"* ]]; then
      strip_invalid_archs "$binary"
    fi

    if [[ $STRIP_BINARY_RETVAL == 1 ]]; then
      # Move the stripped file into its final destination.
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter \"- CVS/\" --filter \"- .svn/\" --filter \"- .git/\" --filter \"- .hg/\" --filter \"- Headers\" --filter \"- PrivateHeaders\" --filter \"- Modules\" \"${DERIVED_FILES_DIR}/${basename}.framework.dSYM\" \"${DWARF_DSYM_FOLDER_PATH}\""
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" --filter "- CVS/" --filter "- .svn/" --filter "- .git/" --filter "- .hg/" --filter "- Headers" --filter "- PrivateHeaders" --filter "- Modules" "${DERIVED_FILES_DIR}/${basename}.framework.dSYM" "${DWARF_DSYM_FOLDER_PATH}"
    else
      # The dSYM was not stripped at all, in this case touch a fake folder so the input/output paths from Xcode do not reexecute this script because the file is missing.
      touch "${DWARF_DSYM_FOLDER_PATH}/${basename}.framework.dSYM"
    fi
  fi
}

# Signs a framework with the provided identity
code_sign_if_enabled() {
  if [ -n "${EXPANDED_CODE_SIGN_IDENTITY}" -a "${CODE_SIGNING_REQUIRED}" != "NO" -a "${CODE_SIGNING_ALLOWED}" != "NO" ]; then
    # Use the current code_sign_identitiy
    echo "Code Signing $1 with Identity ${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    local code_sign_cmd="/usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} ${OTHER_CODE_SIGN_FLAGS} --preserve-metadata=identifier,entitlements '$1'"

    if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
      code_sign_cmd="$code_sign_cmd &"
    fi
    echo "$code_sign_cmd"
    eval "$code_sign_cmd"
  fi
}

# Strip invalid architectures
strip_invalid_archs() {
  binary="$1"
  # Get architectures for current target binary
  binary_archs="$(lipo -info "$binary" | rev | cut -d ':' -f1 | awk '{$1=$1;print}' | rev)"
  # Intersect them with the architectures we are building for
  intersected_archs="$(echo ${ARCHS[@]} ${binary_archs[@]} | tr ' ' '\n' | sort | uniq -d)"
  # If there are no archs supported by this binary then warn the user
  if [[ -z "$intersected_archs" ]]; then
    echo "warning: [CP] Vendored binary '$binary' contains architectures ($binary_archs) none of which match the current build architectures ($ARCHS)."
    STRIP_BINARY_RETVAL=0
    return
  fi
  stripped=""
  for arch in $binary_archs; do
    if ! [[ "${ARCHS}" == *"$arch"* ]]; then
      # Strip non-valid architectures in-place
      lipo -remove "$arch" -output "$binary" "$binary" || exit 1
      stripped="$stripped $arch"
    fi
  done
  if [[ "$stripped" ]]; then
    echo "Stripped $binary of architectures:$stripped"
  fi
  STRIP_BINARY_RETVAL=1
}


if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AAMultiSelectController/AAMultiSelectController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ARNTransitionAnimator/ARNTransitionAnimator.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ARSLineProgress/ARSLineProgress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ASValueTrackingSlider/ASValueTrackingSlider.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AlamofireImage/AlamofireImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Auk/Auk.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BetterSegmentedControl/BetterSegmentedControl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BmoViewPager/BmoViewPager.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Bolts/Bolts.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CCAutocomplete/CCAutocomplete.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CheckboxList/CheckboxList.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CountryPickerView/CountryPickerView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Digger/Digger.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ExpandableLabel/ExpandableLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKCoreKit/FBSDKCoreKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKLoginKit/FBSDKLoginKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKShareKit/FBSDKShareKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FTPopOverMenu_Swift/FTPopOverMenu_Swift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FacebookCore/FacebookCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FacebookLogin/FacebookLogin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FacebookShare/FacebookShare.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMOAuth2/GTMOAuth2.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoneVisible/GoneVisible.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GooglePlacesSearchController/GooglePlacesSearchController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleToolboxForMac/GoogleToolboxForMac.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ISHPullUp/ISHPullUp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ImageSlideshow/ImageSlideshow.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/JGProgressHUD/JGProgressHUD.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/M13Checkbox/M13Checkbox.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MMPlayerView/MMPlayerView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MRCountryPicker/MRCountryPicker.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Masonry/Masonry.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ModernSearchBar/ModernSearchBar.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NVActivityIndicatorView/NVActivityIndicatorView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PageControl/PageControl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PhoneNumberKit/PhoneNumberKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PopOverMenu/PopOverMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PopoverSwift/PopoverSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Protobuf/Protobuf.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Pushy/Pushy.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SVProgressHUD/SVProgressHUD.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Scrollable/Scrollable.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SearchTextField/SearchTextField.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SkyFloatingLabelTextField/SkyFloatingLabelTextField.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapKit/SnapKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Socket.IO-Client-Swift/SocketIO.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Starscream/Starscream.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftCheckboxDialog/SwiftCheckboxDialog.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftEventBus/SwiftEventBus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftHTTP/SwiftHTTP.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftRangeSlider/SwiftRangeSlider.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftShareBubbles/SwiftShareBubbles.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyAvatar/SwiftyAvatar.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyPickerPopover/SwiftyPickerPopover.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TTGSnackbar/TTGSnackbar.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TTRangeSlider/TTRangeSlider.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Toast-Swift/Toast_Swift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/UIScrollView-InfiniteScroll/UIScrollView_InfiniteScroll.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/VideoPlaybackKit/VideoPlaybackKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/XLPagerTabStrip/XLPagerTabStrip.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YNExpandableCell/YNExpandableCell.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/mamba/mamba.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/moa/moa.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_framework "${BUILT_PRODUCTS_DIR}/AAMultiSelectController/AAMultiSelectController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ARNTransitionAnimator/ARNTransitionAnimator.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ARSLineProgress/ARSLineProgress.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ASValueTrackingSlider/ASValueTrackingSlider.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Alamofire/Alamofire.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/AlamofireImage/AlamofireImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Auk/Auk.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BetterSegmentedControl/BetterSegmentedControl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/BmoViewPager/BmoViewPager.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Bolts/Bolts.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CCAutocomplete/CCAutocomplete.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CheckboxList/CheckboxList.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/CountryPickerView/CountryPickerView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Digger/Digger.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ExpandableLabel/ExpandableLabel.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKCoreKit/FBSDKCoreKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKLoginKit/FBSDKLoginKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FBSDKShareKit/FBSDKShareKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FTPopOverMenu_Swift/FTPopOverMenu_Swift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FacebookCore/FacebookCore.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FacebookLogin/FacebookLogin.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/FacebookShare/FacebookShare.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMOAuth2/GTMOAuth2.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GTMSessionFetcher/GTMSessionFetcher.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoneVisible/GoneVisible.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GooglePlacesSearchController/GooglePlacesSearchController.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleToolboxForMac/GoogleToolboxForMac.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/GoogleUtilities/GoogleUtilities.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ISHPullUp/ISHPullUp.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ImageSlideshow/ImageSlideshow.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/JGProgressHUD/JGProgressHUD.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/M13Checkbox/M13Checkbox.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MMPlayerView/MMPlayerView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/MRCountryPicker/MRCountryPicker.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Masonry/Masonry.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/ModernSearchBar/ModernSearchBar.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/NVActivityIndicatorView/NVActivityIndicatorView.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PageControl/PageControl.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PhoneNumberKit/PhoneNumberKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PopOverMenu/PopOverMenu.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/PopoverSwift/PopoverSwift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Protobuf/Protobuf.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Pushy/Pushy.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SDWebImage/SDWebImage.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SVProgressHUD/SVProgressHUD.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Scrollable/Scrollable.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SearchTextField/SearchTextField.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SkyFloatingLabelTextField/SkyFloatingLabelTextField.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SnapKit/SnapKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Socket.IO-Client-Swift/SocketIO.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Starscream/Starscream.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftCheckboxDialog/SwiftCheckboxDialog.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftEventBus/SwiftEventBus.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftHTTP/SwiftHTTP.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftRangeSlider/SwiftRangeSlider.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftShareBubbles/SwiftShareBubbles.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyAvatar/SwiftyAvatar.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/SwiftyPickerPopover/SwiftyPickerPopover.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TTGSnackbar/TTGSnackbar.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/TTRangeSlider/TTRangeSlider.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/Toast-Swift/Toast_Swift.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/UIScrollView-InfiniteScroll/UIScrollView_InfiniteScroll.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/VideoPlaybackKit/VideoPlaybackKit.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/XLPagerTabStrip/XLPagerTabStrip.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/YNExpandableCell/YNExpandableCell.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/leveldb-library/leveldb.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/mamba/mamba.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/moa/moa.framework"
  install_framework "${BUILT_PRODUCTS_DIR}/nanopb/nanopb.framework"
fi
if [ "${COCOAPODS_PARALLEL_CODE_SIGN}" == "true" ]; then
  wait
fi