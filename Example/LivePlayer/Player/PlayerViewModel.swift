//
//  PlayerViewModel.swift
//  LivePlayer_Example
//
//  Created by James Lee on 14/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

final class PlayerViewModel {
    private let live: LiveModel

    var mediaUrl: URL? {
        guard let urlString = live.media_url else { return nil }
        return URL(string: urlString)
    }
    
    init(with live: LiveModel) {
        self.live = live
    }
}
