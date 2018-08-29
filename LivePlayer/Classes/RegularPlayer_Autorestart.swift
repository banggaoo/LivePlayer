//
//  RegularPlayer_Autorestart.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation
import AVFoundation

let LoadingCountDigit = 1
let EmptyCountDigit = 100
let FailedCountDigit = 1000

extension RegularPlayer {
    
    @objc func on(timer: Timer) {
        // Check connection is need to retry
        
        if userWantToPlay {
            
            switch state {
                
            case .empty:  // Might network fail. if live streaming, chunk might created yet
                // Wait and try play
                
                // If live streaming chunk exist, will play chunk
                autoRestartCount += (Int(timer.timeInterval) * EmptyCountDigit)

            case .loading:  // loading or network is slow
                // Wait
                // couldnt play after reconnect live
                
                autoRestartCount += (Int(timer.timeInterval) * LoadingCountDigit)
                break
                
            case .ready:  // normal
                autoRestartCount = 0
                
            case .failed:  // fail to play or file not found 404
                
                autoRestartCount += (Int(timer.timeInterval) * FailedCountDigit)
                
            default:  // unknown
                break
            }
            
            if autoRestartCount >= Int(assetLoadTimeout) * FailedCountDigit {  // try to reload
                guard let asset: AVAsset = self.player.currentItem?.asset else { return }
                
                self.set(asset)
                self.player.play()

            }else if autoRestartCount >= Int(assetEmptyTimeout) * EmptyCountDigit {  // try to play

                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }

            }else if autoRestartCount >= Int(assetPlayTimeout) * LoadingCountDigit {  // try to play
                
                if self.player.timeControlStatus != .playing {
                    self.player.play()
                }
            }
        }
    } 
}
