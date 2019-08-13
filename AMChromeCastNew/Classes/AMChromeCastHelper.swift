//
//  AMChromeCastHelper.swift
//  AMChromeCastNew
//
//  Created by Sarath Yarra on 06/08/19.
//

import UIKit
import GoogleCast
import StoreKit

@objc public protocol AMChromeCastHelperDelegate: NSObjectProtocol {
    @objc func getstreamUrl(completionHandler:(_ streamUrl:String?,_ videoInfo: [AnyHashable: Any]?,_ error: Error?) -> Void)
    func getMediaInformation(completionHandler:(_ mediaObject:AMMediaInformation?, _ playBackMode : PlaybackMode) -> Void)
    func isDeviceConnectedTochromeCast(isconnected :Bool)
}


@objc public enum PlaybackMode : Int {
    case none = 0
    case local
    case remote
}



@objc public class AMChromeCastHelper: NSObject,GCKLoggerDelegate,GCKSessionManagerListener,GCKDiscoveryManagerListener,GCKRequestDelegate,GCKRemoteMediaClientListener {
    @objc public  static let sharedInstance: AMChromeCastHelper = { AMChromeCastHelper() }()
    @objc public var kReceiverAppID = ""
//    @objc public var castButton: GCKUICastButton!
    var _sessionManager : GCKSessionManager?
    var _castMediaController: GCKUIMediaController?
    var _mediaInformation : AMMediaInformation?
    
    public var _playbackMode = PlaybackMode(rawValue: 0)
    @objc public    var _castSession: GCKCastSession?
    var _contentType : String?
    var _imgURL : URL?
    var _viewcontroller : UIViewController?
    var _videoPlayURL : String?
    var _strTitle : String?
    var _strSubTitle : String?
    var _playFairPlay : Bool?
    var _chromecastDolbyUrl : String?
    var _licenseUrl : URL?
    var _drmToken : String?
    var _showWatermark : Bool?
    var _isconnectedToNetwork : Bool?
    var _subTitleUrl : NSString?
    var _strDuration : NSString?
    var _addUrlString : NSString?
    var _arrMediaFiles : NSArray?
    var _adTitle : NSString?
    var _currentPlaybackTime : TimeInterval?
    var _sliderFloatValue : Float?
    
    //MARK : Object for ChromeCastHelperDelegate
    @objc public var delegate : AMChromeCastHelperDelegate?
    
    //MARK : static values define here
    static let kLive = "live"
    static let kProgram = "program"
    
    
    
    
    typealias GckMediaInfoWithCompletionHandler = (_ mediaInfoo: GCKMediaInformation?, _ mediaInfoo1:
        GCKMediaInformation, _ error: Error?) -> Void
    
    //MARK : Initilize the chrome cast
    @objc public   func initializeGoogleChromeCast(receiverId : String) {
        kReceiverAppID = receiverId
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions.init(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        _castMediaController = GCKUIMediaController()
        
        // Enable logger.
        GCKLogger.sharedInstance().delegate = self
        
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        _sessionManager = GCKCastContext.sharedInstance().sessionManager
        _sessionManager!.add(self)
    }
    
    @objc public   func showChromeCastButton(frame : CGRect,view : UIView)  {
        let castButton = GCKUICastButton.init(frame: frame)
        castButton.tintColor = UIColor.white
          view.addSubview(castButton)
    }
    
    //MARK : checking for chrome cast is connected or not
 @objc public   func hasConnectedSession() -> Bool {
        if let sessionManager = _sessionManager {
            return sessionManager.hasConnectedSession()
        }
        return false
    }
    
    //MARK : GCKDiscoveryManagerListener Method
    public func didUpdateDeviceList()  {
        
    }
    //MARK : play the content in local
    func switchToLocalPlayback()
    {
//        if _playbackMode == PlaybackMode.local {
//            return
//        }
//        var playPosition: TimeInterval = 0
//        var paused = false
//        var ended = false
//
//        if _playbackMode == PlaybackMode.remote {
//            playPosition = (_castMediaController?.lastKnownStreamPosition)!
//            paused = _castMediaController?.lastKnownPlayerState == GCKMediaPlayerState.paused
//            ended = _castMediaController?.lastKnownPlayerState == GCKMediaPlayerState.idle
//        }
        
    }
    
    func buildMediaInformation(mediaInformation : AMMediaInformation, withCompletion completionHandler: @escaping GckMediaInfoWithCompletionHandler)
    {
        var metadata: GCKMediaMetadata? = nil
        var metaDataAds : GCKMediaMetadata? = nil
        var mediaAds : GCKMediaInformation? = nil
        if let adUrlString = _mediaInformation?.adUrlString {
            if  mediaInformation.arrMediaFiles != nil {
                metaDataAds = GCKMediaMetadata(metadataType: GCKMediaMetadataType.generic)
                if let title = mediaInformation.contentTitle {
                    metaDataAds?.setString(title as String, forKey: kGCKMetadataKeyTitle)
                }
                if mediaInformation.imageUrl != nil {
                    metaDataAds?.addImage(GCKImage(url: mediaInformation.imageUrl!, width: 480, height: 720))
                    metaDataAds?.addImage(GCKImage(url: mediaInformation.imageUrl!, width: 480, height: 720))
                }
                let streamType = GCKMediaStreamType.buffered
                let contentType = _mediaInformation?.contentFormate
                let playerUrl : String? = adUrlString
                let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL:URL(string: playerUrl!)!)
                mediaInfoBuilder.contentID = playerUrl
                mediaInfoBuilder.streamType = streamType
                mediaInfoBuilder.contentType = contentType
                mediaInfoBuilder.metadata = metaDataAds
                mediaInfoBuilder.streamDuration = 0
                mediaInfoBuilder.mediaTracks = nil
                mediaInfoBuilder.textTrackStyle = nil
                mediaInfoBuilder.customData = ""
                
                mediaAds = mediaInfoBuilder.build()
            }
        }
        else {
            mediaAds = nil
        }
        
        // here we are sending type as Movie, because for livetv and tvshows the title and description not coming in chromecast screen
          metadata = GCKMediaMetadata(metadataType: GCKMediaMetadataType.movie)
        if metadata != nil {
            if mediaInformation.contentTitle != nil {
                metadata?.setString(mediaInformation.contentTitle!, forKey: kGCKMetadataKeyTitle)
            }
            if _strSubTitle != nil {
                metadata?.setString(mediaInformation.subTitle!, forKey: kGCKMetadataKeySubtitle)
            }
            if mediaInformation.imageUrl != nil {
                metaDataAds?.addImage(GCKImage(url: mediaInformation.imageUrl!, width: 480, height: 720))
                metaDataAds?.addImage(GCKImage(url: mediaInformation.imageUrl!, width: 480, height: 720))
            }
            let streamType = ((mediaInformation.contentType == AMChromeCastHelper.kLive) || (mediaInformation.contentType == AMChromeCastHelper.kProgram)) ? GCKMediaStreamType.live : GCKMediaStreamType.buffered
            var playUrl : String = ""
            if mediaInformation.videoUrl != nil {
                playUrl = mediaInformation.videoUrl!
            }
            let contentType = mediaInformation.contentStreamExtension
            let customData = mediaInformation.customData
            let strDuration = mediaInformation.streamDuration
            let duration = (strDuration as NSString?)?.doubleValue
            let mediaInfoBuilder = GCKMediaInformationBuilder(contentURL:URL(string: playUrl)!)
            mediaInfoBuilder.contentID = playUrl
            mediaInfoBuilder.streamType = streamType
            mediaInfoBuilder.contentType = contentType
            mediaInfoBuilder.metadata = metadata
            if duration != nil {
                mediaInfoBuilder.streamDuration = duration!
            }
            else {
                mediaInformation.streamDuration = "0"
            }
            mediaInfoBuilder.mediaTracks = nil
            mediaInfoBuilder.textTrackStyle = nil
            mediaInfoBuilder.customData = customData
            
            let mediaInfo : GCKMediaInformation = mediaInfoBuilder.build()
            completionHandler(mediaAds,mediaInfo,nil)
        }
    }
    
        //MARK : play the content in remote
    @objc public  func playTheContentInChromeCast(mediaInform : AMMediaInformation) {
         self._castSession = _sessionManager?.currentCastSession
        _mediaInformation = mediaInform
        var playPosition = TimeInterval()
        if _mediaInformation?.currentPlaybackTime != nil {
            playPosition = _mediaInformation!.currentPlaybackTime
        }
        else {
            playPosition = 0
        }
        let paused = false
        let builder =  GCKMediaQueueItemBuilder()
        let builder1 = GCKMediaQueueItemBuilder()
        self.buildMediaInformation(mediaInformation: _mediaInformation!) { (_ mediaInfoo: GCKMediaInformation?, _ mediaInfoo1: GCKMediaInformation, _ error:Error? ) in
            var item : GCKMediaQueueItem?
            if mediaInfoo != nil {
                builder.mediaInformation = mediaInfoo
                builder.autoplay = !paused
                builder.preloadTime = 0
                item = builder.build()
            }
            
            builder1.mediaInformation = mediaInfoo1
            builder1.autoplay = !paused
            builder1.preloadTime = 0
            let item1 : GCKMediaQueueItem? = builder1.build()
            
            var array : [GCKMediaQueueItem]!;
            if mediaInfoo != nil {
                array = [item!,item1!];
            }
            else {
                array = [item1!]
            }
//            let queueDataBuilder = GCKMediaQueueDataBuilder(queueType: .movie)
//            queueDataBuilder.items = array
//            queueDataBuilder.repeatMode =  .off
//            let mediaLoadRequestDataBuilder = GCKMediaLoadRequestDataBuilder()
//            mediaLoadRequestDataBuilder.queueData = queueDataBuilder.build()
//
//            let request = self._castSession?.remoteMediaClient?.loadMedia(with: mediaLoadRequestDataBuilder.build())
//            request!.delegate = self
            
            let request: GCKRequest? = self._castSession?.remoteMediaClient?.queueLoad(array, start: 0, playPosition: playPosition, repeatMode: GCKMediaRepeatMode.off, customData: nil)
            request?.delegate = self
            self._castSession?.remoteMediaClient?.add(self as GCKRemoteMediaClientListener)
            self._castSession?.remoteMediaClient?.setStreamVolume(0.5)
        }
        
    }
    
    
    //MARK : GCKSessionManagerListener Methods
    public func sessionManager(_ sessionManager: GCKSessionManager, didStart session: GCKSession) {
        self.delegate?.isDeviceConnectedTochromeCast(isconnected: true)
    }
    public func sessionManager(_ sessionManager: GCKSessionManager, willStart session: GCKSession) {
        
    }
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeSession session: GCKSession) {
        
    }
    public func sessionManager(_ sessionManager: GCKSessionManager, didResumeCastSession session: GCKCastSession) {
        
    }
    public func sessionManager(_ sessionManager: GCKSessionManager, didEnd session: GCKSession, withError error: Error?) {
        if self._castSession != nil {
            self._castSession = nil
        }

        self.delegate?.isDeviceConnectedTochromeCast(isconnected: false)
    }
    
    public func sessionManager(_ sessionManager: GCKSessionManager, didFailToStart session: GCKSession, withError error: Error) {
        
    }
    
    private func requestDidComplete(_ request: GCKRequest) {
        print("\(#function), \(request)")
    }
    private func request(_ request: SKRequest, didFailWithError error: Error) {
        print("\(#function), \(request), error = \(error)")
    }
    private func request(_ request: GCKRequest, didAbortWith abortReason: GCKRequestAbortReason) {
        print("\(#function), \(request), abortReason = \(Float((abortReason).rawValue))")
    }
    
    private func remoteMediaClientDidUpdateQueue(_ client: GCKRemoteMediaClient) {
    }
    
    private func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaMetadata: GCKMediaMetadata?) {
       
    }
    
    private func remoteMediaClient(_ client: GCKRemoteMediaClient, didStartMediaSessionWithID sessionID: Int){
        
    }

    private func remoteMediaClientDidUpdatePreloadStatus(_ client: GCKRemoteMediaClient) {
        
    }
    private func remoteMediaClient(_ client: GCKRemoteMediaClient, didUpdate mediaStatus: GCKMediaStatus?) {
        
    }
    

    
    
    
    
    
}
