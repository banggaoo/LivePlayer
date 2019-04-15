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
    
    var title: String {
        return live.subject ?? "Live"
    }
    
    var coverImageUrl: String? {
        return live.thumbnail_url
    }
    var coverImageName: String? {
        return nil
    }
    
    init(with live: LiveModel) {
        self.live = live
    }
}
