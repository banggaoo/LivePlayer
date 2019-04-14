//
//  RegularPlayerExtension.swift
//  LivePlayer_Example
//
//  Created by James Lee on 14/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import LivePlayer

extension RegularPlayer {
    func changePlayerActionByPlaying() {
        playing ? stop() : start()
    }
}
