//
//  VersaPlayerAdManagerBehaviour.swift
//  VersaPlayer Demo
//
//  Created by Jose Quintero on 10/12/18.
//  Copyright © 2018 Quasar. All rights reserved.
//

import CoreMedia
import Foundation
import VersaPlayer

public class VersaPlayerAdManagerBehaviour {

    public var handler: VersaPlayerAdsManager! {
        didSet {
            configure()
        }
    }

    public var delegate: VersaPlayerAdManagerBehaviourDelegate?

    public func configure() {}

    public func willShowAdsFor(player: VersaPlayer) {
        handler.player.controls?.controlsCoordinator.isHidden = true
//        NotificationCenter.default.addObserver(forName: VersaPlayer.VPlayerNotificationName.play.notification, object: nil, queue: .main) {[weak self] notif in
//            self?.handler.adsManager?.resume()
//        }
//        NotificationCenter.default.addObserver(forName: VersaPlayer.VPlayerNotificationName.pause.notification, object: nil, queue: .main) {[weak self] notif in
//            self?.handler.adsManager?.pause()
//        }

        delegate?.willShowAdsFor(player: player)
    }

    public func didEndAd() {
        // NotificationCenter.default.removeObserver(self)
        handler.player.controls?.controlsCoordinator.isHidden = false
    }
}
