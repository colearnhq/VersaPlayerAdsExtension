//
//  VersaPlayerAds.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/11/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import Foundation
import GoogleInteractiveMediaAds
import VersaPlayer

public class VersaPlayerAdsManager: VersaPlayerExtension, IMAAdsLoaderDelegate, IMAAdsManagerDelegate {

    public var controller: UIViewController!
    public var behaviour: VersaPlayerAdManagerBehaviour!
    public var contentPlayhead: IMAAVPlayerContentPlayhead?
    public var pipProxy: IMAPictureInPictureProxy?
    public var adsLoader: IMAAdsLoader?
    public var adsManager: IMAAdsManager?
    public var tag: String!
    public var showingAds: Bool = false
    public var preRollShown: Bool = false
    public var postRollShown: Bool = false
    public var secondsShown: [Double] = []
    
    public init(with player: VersaPlayer, presentingIn controller: UIViewController) {
        super.init(with: player)
        self.behaviour = VersaPlayerAdManagerBehaviour()
        self.behaviour.handler = self
        self.controller = controller
        setUpContentPlayer()
        setUpAdsLoader()
        player.addObserver(self, forKeyPath: "isPipModeEnabled", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "isPipModeEnabled" {
            if let value = change?[NSKeyValueChangeKey.newKey] as? Bool {
                requestAds(using: value)
            }
        }
    }
    
    public func setUpAdsLoader() {
        adsLoader = IMAAdsLoader(settings: nil)
        adsLoader!.delegate = self
    }
    
    public func requestAds(using pip: Bool = false) {
        let adDisplayContainer = IMAAdDisplayContainer(adContainer: player.renderingView, companionSlots: nil)
        var request: IMAAdsRequest
        if !pip {
            request = IMAAdsRequest(
                adTagUrl: tag,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: contentPlayhead,
                userContext: nil)
        }else {
            if pipProxy == nil {
                pipProxy = IMAPictureInPictureProxy(avPictureInPictureControllerDelegate: player.pipController?.delegate)
                player.pipController?.delegate = pipProxy
            }
            let display = IMAAVPlayerVideoDisplay(avPlayer: player.player)
            request = IMAAdsRequest(
                adTagUrl: tag,
                adDisplayContainer: adDisplayContainer,
                avPlayerVideoDisplay: display,
                pictureInPictureProxy: pipProxy,
                userContext: nil)
        }
        
        adsLoader!.requestAds(with: request)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        adsManager = adsLoadedData.adsManager
        adsManager!.delegate = self
        let adsRenderingSettings = IMAAdsRenderingSettings()
        adsRenderingSettings.webOpenerPresentingController = nil
        
        adsManager!.initialize(with: adsRenderingSettings)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print(adErrorData.adError.message)
    }

    public func setUpContentPlayer() {
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: player.player)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentDidFinishPlaying(notification:)),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.player.currentItem
        )
    }

    @objc public func contentDidFinishPlaying(notification: NSNotification) {
        if let obj = notification.object as? AVPlayerItem {
            if obj == player.player.currentItem {
                adsLoader?.contentComplete()
            }else if showingAds {
                showingAds = false
                behaviour.didEndAd()
            }
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive event: IMAAdEvent!) {
        if (event.type == IMAAdEventType.LOADED) {
            showingAds = true
            behaviour.willShowAdsFor(player: player.player)
            adsManager.start()
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager!, didReceive error: IMAAdError!) {
        player.play()
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager!) {
        player.pause()
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager!) {
        if !player.isPlaying {
            player.play()
        }
    }
    
}