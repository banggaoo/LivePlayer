//
//  LiveModel.swift
//  GDNY
//
//  Created by st on 24/07/2018.
//  Copyright © 2018 st. All rights reserved.
//

import Foundation

final class LiveModel: Codable {

    private(set) var id: Int?
    private(set) var code_name: String?
    private(set) var subject: String?
    private(set) var media_url: String?
    private(set) var thumbnail_url: String?
    private(set) var premium: Bool?
    private(set) var screen_direction: String?
    private(set) var likes_count: Int?
    private(set) var bookmarks_count: Int?
    private(set) var media_type: String?
    //var live_channel: LiveChannelModel?
    
    static func decodeJsonData(jsonString: String) -> LiveModel? {
        do {
            return try JSONDecoder().decode(LiveModel.self, from: jsonString.data(using: .utf8)!)
        } catch {
            printLog("Parsing Error \(error)")
        }
        return nil
    }
}
