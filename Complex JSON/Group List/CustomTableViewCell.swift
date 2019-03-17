//
//  CustomTableViewCell.swift
//  Complex JSON
//
//  Created by snapmac on 2/21/18.
//  Copyright © 2018 snapmac. All rights reserved.
//

import UIKit
import VideoPlaybackKit

class CustomTableViewCell: UITableViewCell, VPKViewInCellProtocol {
    var videoView: VPKVideoView?
    static let identifier = "VideoCell"
    @IBOutlet weak var imageosh: UIImageView!
    @IBOutlet weak var totalMembersLbl: UILabel!
    @IBOutlet weak var startDayLbl: UILabel!
    @IBOutlet weak var tableviewCell: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var groupLeaderLbl: UILabel!
    @IBOutlet weak var newPrice: UILabel!
    @IBOutlet weak var groupLeaderImageView: UIImageView!
    @IBOutlet weak var frequencyDescrptionLbl: UILabel!
    @IBOutlet weak var slashImage: UIImageView!
    @IBOutlet weak var dateAndNightsLbl: UILabel!
    @IBOutlet weak var frequencyLbl: UILabel!
    @IBOutlet weak var tagLinefrequencyView: UIView!
    @IBOutlet weak var contsratWidthImage: NSLayoutConstraint!
    @IBOutlet weak var interstedLbl: UILabel!
    @IBOutlet weak var totalDaysLbl: UILabel!
    @IBOutlet weak var intrestedView: UIView!
    @IBOutlet weak var membersIcon: UIImageView!
    @IBOutlet weak var ItineraryImage: UIImageView!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var daysNumbers: UILabel!
    @IBOutlet weak var daysLbl: UILabel!
    @IBOutlet weak var progressImage: UIActivityIndicatorView!
    @IBOutlet weak var isReccuring: UIImageView!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var privateIcon: UIImageView!
    @IBOutlet weak var openIcon: UIImageView!
    @IBOutlet weak var leaderIcon: UIImageView!
    @IBOutlet weak var memberIcon: UIImageView!
    @IBOutlet weak var inviteIcon: UIImageView!
    @IBOutlet weak var timeOutIcon: UIImageView!
    @IBOutlet weak var isSaleGroup: UIView!
    
    @IBOutlet weak var oldView: UIView!
    
    @IBOutlet weak var demoGroup: UIView!
    @IBOutlet weak var priceTemplatView: UIView!
    @IBOutlet weak var viewInfo: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        prepareForVideoReuse() //Extension default
    }



}
