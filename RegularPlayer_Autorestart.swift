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
            
            if state == .ready {
                autoRestartCount = 0
                
            }else if state == .loading{
                autoRestartCount += 1
                
            }else if state == .failed{
                autoRestartCount += 1
                
                if autoRestartCount > 5 {
                    //nslog("autoRestartCount > 5")
                    // cannot catch if video loading is quite long
                    
                    autoRestartCount = 1
                    
                    guard let asset: AVAsset = self.player.currentItem?.asset else { return }
                    
                    set(asset)
                    return
                }
            }
            
            if autoRestartCount > 0 {
                //nslog("autoRestartCount > 0")
                
                play()
            }
        }
    }
}
