//
//  RegularPlayer_Observer.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation
import AVFoundation

extension RegularPlayer {
    
    func addPlayerItemObservers(toPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.addObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.LoadedTimeRanges, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.PlaybackBufferEmpty, options: [.initial, .new], context: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(newErrorLogEntry(notification:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackStalled(notification:)), name: .AVPlayerItemPlaybackStalled, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackDidPlayToEndTime(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func removePlayerItemObservers(fromPlayerItem playerItem: AVPlayerItem)
    {
        playerItem.removeObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.LoadedTimeRanges, context: nil)
        playerItem.removeObserver(self, forKeyPath: RegularPlayerKeyPath.PlayerItem.PlaybackBufferEmpty, context: nil)
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
    }
    
    func addPlayerObservers()
    {
        self.player.addObserver(self, forKeyPath: RegularPlayerKeyPath.Player.Rate, options: [.initial, .new], context: nil)
        self.player.addObserver(self, forKeyPath: RegularPlayerKeyPath.Player.Status, options: [.initial, .new], context: nil)
        self.player.addObserver(self, forKeyPath: RegularPlayerKeyPath.Player.TimeControlStatus, options: [.initial, .new], context: nil)
        
        self.playerTimeObserver = self.player.addPeriodicTimeObserver(forInterval: getSeekTime(to: timeUpdateInterval), queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            
            if let strongSelf = self, let time = cmTime.timeInterval
            {
                strongSelf.time = time
            }
        })
    }
    
    func removePlayerObservers()
    {
        self.player.removeObserver(self, forKeyPath: RegularPlayerKeyPath.Player.Rate, context: nil)
        self.player.removeObserver(self, forKeyPath: RegularPlayerKeyPath.Player.Status, context: nil)
        self.player.removeObserver(self, forKeyPath: RegularPlayerKeyPath.Player.TimeControlStatus, context: nil)
        
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
            
            if keyPath == RegularPlayerKeyPath.Player.Rate
            {
                if let rate = change?[.newKey] as? Float
                {
                    self.playerRateDidChange(rate: rate)
                }
            }
            else if keyPath == RegularPlayerKeyPath.Player.Status
            {
                if let statusInt = change?[.newKey] as? Int, let status = AVPlayer.Status(rawValue: statusInt)
                {
                    self.playerStatusDidChange(status: status)
                }
            }
            else if keyPath == RegularPlayerKeyPath.Player.TimeControlStatus
            {
                if let statusInt = change?[.newKey] as? Int, let status = AVPlayer.TimeControlStatus(rawValue: statusInt)
                {
                    self.playerTimeControlStatusDidChange(status: status)
                }
            }
        }else if let _: AVPlayerItem = object as? AVPlayerItem {
            
            if keyPath == RegularPlayerKeyPath.PlayerItem.Status
            {
                if let statusInt = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: statusInt)
                {
                    self.playerItemStatusDidChange(status: status)
                }
            }
            else if keyPath == RegularPlayerKeyPath.PlayerItem.PlaybackLikelyToKeepUp
            {
                if let playbackLikelyToKeepUp = change?[.newKey] as? Bool
                {
                    self.playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp: playbackLikelyToKeepUp)
                }
            }
            else if keyPath == RegularPlayerKeyPath.PlayerItem.LoadedTimeRanges
            {
                if let loadedTimeRanges = change?[.newKey] as? [NSValue]
                {
                    self.playerItemLoadedTimeRangesDidChange(loadedTimeRanges: loadedTimeRanges)
                }
            }
            else if keyPath == RegularPlayerKeyPath.PlayerItem.PlaybackBufferEmpty
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
    
    private func playerItemStatusDidChange(status: AVPlayerItem.Status)
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
    
    private func playerStatusDidChange(status: AVPlayer.Status)
    {
        // not accurate
        /*
        switch status
        {
        case .unknown:
            
            self.state = .unknown
            
        case .readyToPlay:
            
            self.state = .ready
            
        case .failed:
            
            self.state = .failed
        }*/
    }
    
    @objc func newErrorLogEntry(notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return }
        
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        
        //nslog("newErrorLogEntry Error: \(errorLog)")
        
        // If File Not Found(404) error, retry a few minutes ago
        
        if errorLog.description.contains("404") {
            //nslog("404")
            
            self.state = .failed
        }
    }
    
    @objc func failedToPlayToEndTime(notification: Notification) {
        guard let userInfo = notification.userInfo, let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else { return }
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        //nslog("failedToPlayToEndTime Error: \(error)")
        
        if error.localizedDescription.contains("404") {
            //nslog("404")
            
            self.state = .failed
        }
    }
    
    @objc func playbackStalled(notification: Notification) {
        guard let _ = notification.userInfo else { return }
        
        //nslog("playbackStalled notification: \(notification)")
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        
        guard let isPlaybackBufferEmpty = player.currentItem?.isPlaybackBufferEmpty else { return }
        
        self.state = isPlaybackBufferEmpty ? .empty : .loading
    }
    
    @objc func playbackDidPlayToEndTime(notification: Notification) {
        guard let _ = notification.userInfo else { return }
        
        //nslog("playbackDidPlayToEndTime notification: \(notification)")
        
        //let error: NSError = notification.userInfo?["AVPlayerItemFailedToPlayToEndTimeErrorKey"] as! NSError
        
        self.state = .ready
    }
    
    private func playerTimeControlStatusDidChange(status: AVPlayer.TimeControlStatus)
    {
        self.delegate?.playerDidUpdatePlaying(player: self)
        
        if self.player.timeControlStatus == .playing {
            
            self.state = .ready

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
                guard let strongSelf = self else { return }
                
                if strongSelf.player.timeControlStatus != .paused {
                    //nslog("preferredPeakBitRate = 1024 * 1024 * 4")
                    strongSelf.player.currentItem?.preferredPeakBitRate = 1024 * 1024 * 4
                }
            })
        }else if self.player.timeControlStatus == .waitingToPlayAtSpecifiedRate {
            // Not accurate
            //self.state = .loading
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
