//
//  RegularPlayer_Autorestart.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation
import AVFoundation

extension RegularPlayer {
    
    @objc func on(timer: Timer) {
        // Check connection is need to retry
        
        if userWantToPlay {
            
            switch state {
                
            case .empty:  // Might network fail. if live streaming, chunk might created yet
                // Wait and try play
                
                // If live streaming chunk exist, will play chunk
                autoRestartCount += Int(timer.timeInterval)

            case .loading:  // loading or nework is slow
                // Wait
                break
                
            case .ready:  // normal
                autoRestartCount = 0
                
            case .failed:  // fail to play or file not found 404
                
                autoRestartCount += (Int(timer.timeInterval) * 100)
                
            default:  // unknown
                break
            }
            
            if autoRestartCount >= Int(assetLoadTimeout * 100.0) {  // try to reload
                guard let asset: AVAsset = self.player.currentItem?.asset else { return }
                
                self.set(asset)
                self.player.play()

            }else if autoRestartCount > Int(assetPlayTimeout) {  // try to play
                
                self.player.play()
            }
        }
    } 
}
