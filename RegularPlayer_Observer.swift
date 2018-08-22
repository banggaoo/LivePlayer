//
//  RegularPlayer_Observer.swift
//  LivePlayer
//
//  Created by st on 22/08/2018.
//

import Foundation
import AVKit

extension RegularPlayer {
    
    // MARK: Observers
    
    private struct KeyPath
    {
        struct Player
        {
            static let Rate = "rate"
        }
        
        struct PlayerItem
        {
            static let Status = "status"
            static let PlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
            static let LoadedTimeRanges = "loadedTimeRanges"
        }
    }
    
    @objc func newErrorLogEntry(notification: Notification) {
        
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return }
        
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        
        NSLog("newErrorLogEntry Error: \(errorLog)")
        
        // If File Not Found(404) error, retry a few minutes ago
        
        if errorLog.description.contains("404") {
            NSLog("404")
            
            autoRestartCount += 1

            turnAutoReloadOnDelay()
        }
    }
    
    @objc func failedToPlayToEndTime(notification: Notification) {
        
        guard let userInfo = notification.userInfo, let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else {
            return
        }
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        NSLog("failedToPlayToEndTime Error: \(error)")
        
        if error.localizedDescription.contains("404") {
            NSLog("404")
            
            autoRestartCount += 1
            
            turnAutoReloadOnDelay()
        }
    }
    
    @objc func playbackStalled(notification: Notification) {
        NSLog("playbackStalled notification: \(notification)")

        guard let userInfo = notification.userInfo else { return }
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        
    }
    
    func turnAutoReloadOnDelay() {
        
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            
            guard let strongSelf = weakSelf else { return }
            
            if strongSelf.autoRestartCount > 0 {
                
                strongSelf.autoRestartCount += 5
            }
        }
    }
    
    func addPlayerItemObservers(toPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.initial, .new], context: nil)
        player.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(newErrorLogEntry(notification:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackStalled(notification:)), name: .AVPlayerItemPlaybackStalled, object: player.currentItem)
    }
    
    func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
        playerItem.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: nil)
        player.removeObserver(self, forKeyPath: "status", context: nil)
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
    }
    
    func addPlayerObservers()
    {
        self.player.addObserver(self, forKeyPath: KeyPath.Player.Rate, options: [.initial, .new], context: nil)
        
        self.playerTimeObserver = self.player.addPeriodicTimeObserver(forInterval: getSeekTime(to: Constants.TimeUpdateInterval), queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            
            if let strongSelf = self, let time = cmTime.timeInterval
            {
                strongSelf.time = time
            }
        })
    }
    
    func removePlayerObservers()
    {
        self.player.removeObserver(self, forKeyPath: KeyPath.Player.Rate, context: nil)
        
        if let playerTimeObserver = self.playerTimeObserver
        {
            self.player.removeTimeObserver(playerTimeObserver)
            
            self.playerTimeObserver = nil
        }
    }
    
    // MARK: Observation
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        // Player Item Observers
        print("observeValue \(String(describing: keyPath)) \(String(describing: object))")
        
        if keyPath == KeyPath.PlayerItem.Status
        {
            if let statusInt = change?[.newKey] as? Int, let status = AVPlayerItemStatus(rawValue: statusInt)
            {
                self.playerItemStatusDidChange(status: status)
            }
        }
        else if keyPath == KeyPath.PlayerItem.PlaybackLikelyToKeepUp
        {
            if let playbackLikelyToKeepUp = change?[.newKey] as? Bool
            {
                
                //self.player.playImmediately(atRate: 1.0)
                self.play()
                
                self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
            }
        }
        else if keyPath == KeyPath.PlayerItem.LoadedTimeRanges
        {
            if let loadedTimeRanges = change?[.newKey] as? [NSValue]
            {
                autoRestartCount = 0
                self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
            }
        }
            
            // Player Observers
            
        else if keyPath == KeyPath.Player.Rate
        {
            if let rate = change?[.newKey] as? Float
            {
                self.playerRateDidChange(rate: rate)
            }
        }
            
            // Player Observers
            
        else if keyPath == "playbackBufferEmpty"
        {
            if let playbackBufferEmpty = change?[.newKey] as? Bool
            {
                autoRestartCount = autoRestartCount + 1
                
                //self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
            }
        }
            
            // Fall Through Observers
            
        else
        {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: Observation Helpers
    
    private func playerItemStatusDidChange(status: AVPlayerItemStatus)
    {
        switch status
        {
        case .unknown:
            
            self.state = .loading
            
        case .readyToPlay:
            
            self.state = .ready
            
        case .failed:
            
            self.state = .failed
        }
        
        // player.reasonForWaitingToPlay == AVPlayer.WaitingReason.noItemToPlay
    }
    
    private func playerRateDidChange(rate: Float)
    {
        self.delegate?.playerDidUpdatePlaying(player: self)
    }
    
    private func playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: Bool)
    {
        print("playerItemPlaybackLikelyToKeepUpDidChange")
        let state: PlayerState = playbackLikelyToKeepUp ? .ready : .loading
        
        self.state = state
    }
    
    private func playerItemLoadedTimeRangesDidChange(loadedTimeRanges: [NSValue])
    {
        guard let bufferedCMTime = loadedTimeRanges.first?.timeRangeValue.end, let bufferedTime = bufferedCMTime.timeInterval else
        {
            return
        }
        
        self.bufferedTime = bufferedTime
    }
}
