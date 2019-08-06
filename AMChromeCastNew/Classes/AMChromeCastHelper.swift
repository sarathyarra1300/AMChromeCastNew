//
//  AMChromeCastHelper.swift
//  AMChromeCastNew
//
//  Created by Sarath Yarra on 06/08/19.
//

import UIKit
import GoogleCast



@objc public class AMChromeCastHelper: NSObject,GCKLoggerDelegate,GCKSessionManagerListener,GCKDiscoveryManagerListener,GCKRequestDelegate {
    @objc public let kReceiverAppID = ""
    var _sessionManager : GCKSessionManager?
    var _castMediaController: GCKUIMediaController?
    public  static let sharedInstance: AMChromeCastHelper = { AMChromeCastHelper() }()
    
    
    // Initilize the chrome cast
    @objc  public func InitilizeChromeCast ()
    {
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions.init(discoveryCriteria: criteria)
        GCKCastContext.setSharedInstanceWith(options)
        _castMediaController = GCKUIMediaController()
        
        // Enable logger.
        GCKLogger.sharedInstance().delegate = self
        
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        _sessionManager = GCKCastContext.sharedInstance().sessionManager
        _sessionManager!.add(self)
        print("google chrome cast initilization")
    }
    
}
