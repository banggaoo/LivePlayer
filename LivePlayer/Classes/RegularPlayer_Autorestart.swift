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
                autoRestartEmptyCount += Int(timer.timeInterval)

            case .loading:  // loading or network is slow
                // Wait
                // couldnt play after reconnect live
                
                autoRestartLoadCount += Int(timer.timeInterval)
                break
                
            case .ready:  // normal
                autoRestartFailedCount = 0
                autoRestartEmptyCount = 0
                autoRestartLoadCount = 0

            case .failed:  // fail to play or file not found 404
                
                autoRestartFailedCount += Int(timer.timeInterval)
                
            default:  // unknown
                break
            }
            
            if autoRestartFailedCount > Int(assetFailedTimeout) {  // try to reload
                guard let asset: AVAsset = self.player.currentItem?.asset else { return }
                
                self.set(asset)
                self.player.play()

            }else if autoRestartEmptyCount > Int(assetEmptyTimeout) {  // try to play

                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }

            }else if autoRestartLoadCount > Int(assetLoadTimeout)  {  // try to play
                
                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }
            }
        }
    } 
}
