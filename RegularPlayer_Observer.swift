//
//  RegularPlayer_Observer.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation
import AVFoundation

extension RegularPlayer {
        
    @objc func newErrorLogEntry(notification: Notification) {
        
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return }
        
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        
        //nslog("newErrorLogEntry Error: \(errorLog)")
        
        // If File Not Found(404) error, retry a few minutes ago
        
        if errorLog.description.contains("404") {
            //nslog("404")
            
            turnAutoReloadOnDelay()
        }
    }
    
    @objc func failedToPlayToEndTime(notification: Notification) {
        
        guard let userInfo = notification.userInfo, let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else {
            return
        }
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        //nslog("failedToPlayToEndTime Error: \(error)")
        
        if error.localizedDescription.contains("404") {
            //nslog("404")
            
            turnAutoReloadOnDelay()
        }
    }
    
    @objc func playbackStalled(notification: Notification) {
        //nslog("playbackStalled notification: \(notification)")
        
        guard let userInfo = notification.userInfo else { return }
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        
    }
    
    @objc func playbackDidPlayToEndTime(notification: Notification) {
        //nslog("playbackDidPlayToEndTime notification: \(notification)")
        
        guard let userInfo = notification.userInfo else { return }
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        
    }
    
    func turnAutoReloadOnDelay() {
        
        autoRestartCount += 1
        
        weak var weakSelf = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            
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
        playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackBufferEmpty, options: [.initial, .new], context: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(newErrorLogEntry(notification:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackStalled(notification:)), name: .AVPlayerItemPlaybackStalled, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackDidPlayToEndTime(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
        playerItem.removeObserver(self, forKeyPath: KeyPath.PlayerItem.PlaybackBufferEmpty, context: nil)
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
    }
    
    func addPlayerObservers()
    {
        self.player.addObserver(self, forKeyPath: KeyPath.Player.Rate, options: [.initial, .new], context: nil)
        self.player.addObserver(self, forKeyPath: KeyPath.Player.Status, options: [.initial, .new], context: nil)
        self.player.addObserver(self, forKeyPath: KeyPath.Player.TimeControlStatus, options: [.initial, .new], context: nil)
        
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
        self.player.removeObserver(self, forKeyPath: KeyPath.Player.Status, context: nil)
        self.player.removeObserver(self, forKeyPath: KeyPath.Player.TimeControlStatus, context: nil)
        
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
        //print("observeValue \(String(describing: keyPath)) \(String(describing: object))")
        
        if let _: AVPlayer = object as? AVPlayer {
            
            // Player Observers
            
            if keyPath == KeyPath.Player.Rate
            {
                if let rate = change?[.newKey] as? Float
                {
                    self.playerRateDidChange(rate: rate)
                }
            }
            else if keyPath == KeyPath.Player.Status
            {
                if let statusInt = change?[.newKey] as? Int, let status = AVPlayerStatus(rawValue: statusInt)
                {
                    self.playerStatusDidChange(status: status)
                }
            }
            else if keyPath == KeyPath.Player.TimeControlStatus
            {
                if let statusInt = change?[.newKey] as? Int, let status = AVPlayerTimeControlStatus(rawValue: statusInt)
                {
                    self.playerTimeControlStatusDidChange(status: status)
                }
            }
        }else if let _: AVPlayerItem = object as? AVPlayerItem {
            
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
                    self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
                }
            }
            else if keyPath == KeyPath.PlayerItem.LoadedTimeRanges
            {
                if let loadedTimeRanges = change?[.newKey] as? [NSValue]
                {
                    self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
                }
            }
            else if keyPath == KeyPath.PlayerItem.PlaybackBufferEmpty
            {
                if let playbackBufferEmpty = change?[.newKey] as? Bool
                {
                    self.playbackBufferEmptyDidChange(playbackBufferEmpty: playbackBufferEmpty)
                }
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
            
            self.state = .unknown
            
        case .readyToPlay:
            
            self.state = .ready
            
        case .failed:
            
            self.state = .failed
        }
    }
    
    private func playerStatusDidChange(status: AVPlayerStatus)
    {
        switch status
        {
        case .unknown:
            
            self.state = .unknown
            
        case .readyToPlay:
            
            self.state = .ready
            
        case .failed:
            
            self.state = .failed
        }
    }
    
    private func playerTimeControlStatusDidChange(status: AVPlayerTimeControlStatus)
    {
        self.delegate?.playerDidUpdatePlaying(player: self)
        
        if self.player.timeControlStatus == .playing {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if strongSelf.player.timeControlStatus != .paused {
                    //nslog("preferredPeakBitRate = 1024 * 1024 * 4")
                    strongSelf.player.currentItem?.preferredPeakBitRate = 1024 * 1024 * 4
                }
            })
        }
    }
    
    private func playerRateDidChange(rate: Float)
    {
        //self.delegate?.playerDidUpdatePlaying(player: self)
    }
    
    private func playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: Bool)
    {
        //print("playerItemPlaybackLikelyToKeepUpDidChange")
        self.state = playbackLikelyToKeepUp ? .ready : .loading
    }
    
    private func playbackBufferEmptyDidChange(playbackBufferEmpty: Bool)
    {
        //print("playbackBufferEmptyDidChange")
        self.state = playbackBufferEmpty ? .empty : .loading
    }
    
    private func playerItemLoadedTimeRangesDidChange(loadedTimeRanges: [NSValue])
    {
        guard let bufferedCMTime = loadedTimeRanges.first?.timeRangeValue.end, let bufferedTime = bufferedCMTime.timeInterval else { return }
        
        self.bufferedTime = bufferedTime
    }
}
