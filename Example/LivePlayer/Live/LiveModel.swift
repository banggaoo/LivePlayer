//
//  LiveModel.swift
//  GDNY
//
//  Created by st on 24/07/2018.
//  Copyright © 2018 st. All rights reserved.
//

import Foundation

class LiveModel: Codable {

    var id: Int?
    var code_name: String?
    var subject: String?
    var media_url: String?
    var thumbnail_url: String?
    var premium: Bool?
    var screen_direction: String?
    var likes_count: Int?
    var bookmarks_count: Int?
    var media_type: String?
    //var live_channel: LiveChannelModel?
}
