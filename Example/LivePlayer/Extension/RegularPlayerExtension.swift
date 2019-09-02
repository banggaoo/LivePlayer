//
//  RegularPlayerExtension.swift
//  LivePlayer_Example
//
//  Created by James Lee on 02/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import LivePlayer

extension RegularPlayer {
    func setDefaultOption() {
        struct Option {
            static let reloadTimeout: TimeInterval = 10
            static let emptyTimeout: TimeInterval = 10
            static let emptyReloadTimeout: TimeInterval = 10
            static let loadingTimeout: TimeInterval = 10
            static let loadingReloadTimeout: TimeInterval = 10
        }
        
        view.contentMode = .scaleAspectFit
        assetFailedReloadTimeout = Option.reloadTimeout
        assetEmptyTimeout = Option.emptyTimeout
        assetEmptyReloadTimeout = Option.emptyReloadTimeout
        assetLoadingTimeout = Option.loadingTimeout
        assetLoadingReloadTimeout = Option.loadingReloadTimeout
    }
}
