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
        var model = LivesModel()
        do {
            model = try JSONDecoder().decode(LivesModel.self, from: jsonString.data(using: .utf8)!)
        } catch {
            //print("Parsing Error \(error)")
            return nil
        }

        return model
    }
}
