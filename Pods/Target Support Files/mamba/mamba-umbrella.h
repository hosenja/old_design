#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HLSRapidParser.h"
#import "HLSRapidParserCallback.h"
#import "HLSStringRef.h"
#import "HLSStringRefFactory.h"
#import "HLSStringRef_ConcreteNSData.h"
#import "HLSStringRef_ConcreteNSString.h"
#import "HLSStringRef_ConcreteUnownedBytes.h"
#import "RapidParserMasterParseArray.h"
#import "RapidParser.h"
#import "RapidParserDebug.h"
#import "RapidParserError.h"
#import "RapidParserLineState.h"
#import "RapidParserNewTagCallbacks.h"
#import "RapidParserState.h"
#import "RapidParserStateHandlers.h"
#import "CMTimeMakeFromString.h"
#import "mamba.h"

FOUNDATION_EXPORT double mambaVersionNumber;
FOUNDATION_EXPORT const unsigned char mambaVersionString[];

