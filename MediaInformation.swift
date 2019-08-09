//
//  MediaInformation.swift
//  Chrome Cast
//
//  Created by Sarath Yarra on 31/07/19.
//  Copyright © 2019 apalya. All rights reserved.
//

import UIKit
import GoogleCast

@objc public class MediaInformation: NSObject {
@objc public var contentID : String? = nil
@objc public var videoUrl : String? = nil
@objc public var streamType : String? = nil
@objc public var contentType : String? = nil
@objc public var streamDuration : String? = nil
@objc public var subTilteUrl : String? = nil
@objc public var subTitleContentType : String? = nil
@objc public var subTitlesLangName : String? = nil
@objc public var subTitlesLangCode : String? = nil
@objc public var imageUrl : URL? = nil
@objc public var contentTotalDuration : String?
@objc public var contentTitle : String?
@objc public var subTitle : String?
@objc public var currentPlaybackTime : TimeInterval = 0.0
@objc public var licenseUrl : String? = nil
@objc public var drmToken : String? = nil
@objc public var adUrlString : String? = nil
@objc public var contentFormate : String? = nil
@objc public var textTrackStyle : GCKMediaTextTrackStyle? = nil
@objc public var arrMediaFiles : NSArray?
@objc public var customData : NSMutableDictionary? = nil
@objc public var playFairPlay : Bool = false
@objc public var chromecastDolbyUrl : String?
@objc public var isconnectedToNetwork : Bool = false
}
