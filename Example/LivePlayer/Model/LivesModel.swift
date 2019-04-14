//
//  LivesModel.swift
//  GDNY
//
//  Created by st on 24/07/2018.
//  Copyright © 2018 st. All rights reserved.
//

import Foundation

class LivesModel: Codable {
    //var meta: ResponseModel?
    var media: [LiveModel]?

    static func decodeJsonData(jsonString: String) -> LivesModel? {
        do {
            return try JSONDecoder().decode(LivesModel.self, from: jsonString.data(using: .utf8)!)
        } catch {
            printLog("Parsing Error \(error)")
        }
        return nil
    }
}
