//
//  AVAudioSessionExtension.swift
//  LivePlayer_Example
//
//  Created by James Lee on 02/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//


import AVFoundation

extension AVAudioSession {
    func setAmbientCategory() {
        try? AVAudioSession.sharedInstance().setCategory(
            AVAudioSession.Category.ambient,
            mode: AVAudioSession.Mode.moviePlayback,
            options: [.mixWithOthers])
    }
}
