//
//  RegularPlayer_Observer.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation
import AVFoundation

extension RegularPlayer {
    
    public struct KeyPath {
        
        struct Player {
            static let Status = "status"
            static let TimeControlStatus = "timeControlStatus"
        }
        
        struct PlayerItem {
            static let Status = "status"
            static let PlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
            static let LoadedTimeRanges = "loadedTimeRanges"
            static let PlaybackBufferEmpty = "playbackBufferEmpty"
        }
    }

    // MARK: Register
    
    func addPlayerItemObservers(to playerItem: AVPlayerItem) {

        playerItem.addObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.PlaybackLikelyToKeepUp, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.LoadedTimeRanges, options: [.initial, .new], context: nil)
        playerItem.addObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.PlaybackBufferEmpty, options: [.initial, .new], context: nil)
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(newErrorLogEntry(notification:)), name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.addObserver(self, selector: #selector(failedToPlayToEndTime(notification:)), name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackStalled(notification:)), name: .AVPlayerItemPlaybackStalled, object: player.currentItem)
        center.addObserver(self, selector: #selector(playbackDidPlayToEndTime(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func removePlayerItemObservers(from playerItem: AVPlayerItem) {
        playerItem.removeObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.Status, context: nil)
        playerItem.removeObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.PlaybackLikelyToKeepUp, context: nil)
        playerItem.removeObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.LoadedTimeRanges, context: nil)
        playerItem.removeObserver(self, forKeyPath: RegularPlayer.KeyPath.PlayerItem.PlaybackBufferEmpty, context: nil)
        
        let center = NotificationCenter.default
        center.removeObserver(self, name: .AVPlayerItemNewErrorLogEntry, object: player.currentItem)
        center.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: player.currentItem)
        center.removeObserver(self, name: .AVPlayerItemPlaybackStalled, object: player.currentItem)
        center.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func addPlayerObservers() {
        player.addObserver(self, forKeyPath: RegularPlayer.KeyPath.Player.Status, options: [.initial, .new], context: nil)
        player.addObserver(self, forKeyPath: RegularPlayer.KeyPath.Player.TimeControlStatus, options: [.new, .old], context: nil)
        
        playerTimeObserver = player.addPeriodicTimeObserver(forInterval: getSeekTime(to: timeUpdateInterval), queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            guard let time = cmTime.timeInterval else { return }
            self?.time = time
        })
    }
    
    func removePlayerObservers() {
        player.removeObserver(self, forKeyPath: RegularPlayer.KeyPath.Player.Status, context: nil)
        player.removeObserver(self, forKeyPath: RegularPlayer.KeyPath.Player.TimeControlStatus, context: nil)
        
        guard let playerTimeObserver = playerTimeObserver else { return }
        player.removeTimeObserver(playerTimeObserver)
        self.playerTimeObserver = nil
    }
    
    // MARK: Observation
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        printLog("observeValue \(String(describing: keyPath)) \(String(describing: object))")
        
        if let _: AVPlayer = object as? AVPlayer {
            observeAVPlayerValue(forKeyPath: keyPath, of: object, change: change, context: context)
        } else if let _: AVPlayerItem = object as? AVPlayerItem {
            observeAVPlayerItemValue(forKeyPath: keyPath, of: object, change: change, context: context)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func observeAVPlayerValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == RegularPlayer.KeyPath.Player.Status {
            guard
                let statusInt = change?[.newKey] as? Int,
                let status = AVPlayer.Status(rawValue: statusInt) else { return }
            playerStatusDidChange(status: status)
            
        } else if keyPath == RegularPlayer.KeyPath.Player.TimeControlStatus {
            guard
                let statusInt = change?[.newKey] as? Int,
                let status = AVPlayer.TimeControlStatus(rawValue: statusInt) else { return }
            playerTimeControlStatusDidChange(status: status)
        }
    }
    
    private func observeAVPlayerItemValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if keyPath == RegularPlayer.KeyPath.PlayerItem.Status {
            guard
                let statusInt = change?[.newKey] as? Int,
                let status = AVPlayerItem.Status(rawValue: statusInt) else { return }
            playerItemStatusDidChange(status: status)
            
        } else if keyPath == RegularPlayer.KeyPath.PlayerItem.PlaybackLikelyToKeepUp {
            guard let playbackLikelyToKeepUp = change?[.newKey] as? Bool else { return }
            playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp)
            
        } else if keyPath == RegularPlayer.KeyPath.PlayerItem.LoadedTimeRanges {
            guard let loadedTimeRanges = change?[.newKey] as? [NSValue] else { return }
            playerItemLoadedTimeRangesDidChange(loadedTimeRanges)
            
        } else if keyPath == RegularPlayer.KeyPath.PlayerItem.PlaybackBufferEmpty {
            guard let playbackBufferEmpty = change?[.newKey] as? Bool else { return }
            playbackBufferEmptyDidChange(playbackBufferEmpty)
        }
    }
    
    // MARK: Observation Helpers
    
    private func playerItemStatusDidChange(status: AVPlayerItem.Status) {
        switch status {
        case .unknown: state = .unknown
        case .readyToPlay: state = .ready
        case .failed: state = .failed
        @unknown default:
            printLog("playerItemStatusDidChange default exist")
        }
    }
    
    private func playerStatusDidChange(status: AVPlayer.Status) {
        switch status {
        case .unknown: state = .unknown
        case .readyToPlay: state = .ready
        case .failed: state = .failed
        @unknown default:
            printLog("playerStatusDidChange default exist")
        }
    }
    private func playerTimeControlStatusDidChange(status: AVPlayer.TimeControlStatus) {
        delegate?.playerDidUpdateTimeControlStatus(player: self)

        guard changeStateIfWaitingStatus(status) == false else { return }
        guard changeStateIfPlayingStatus(status) == true else {
            upBitrateIfCanAfter(TimeInterval(1))
            return
        }
    }
    
    private func changeStateIfWaitingStatus(_ status: AVPlayer.TimeControlStatus) -> Bool {
        guard status == .waitingToPlayAtSpecifiedRate else { return false }
        state = .loading
        return true
    }
    private func changeStateIfPlayingStatus(_ status: AVPlayer.TimeControlStatus) -> Bool {
        guard status == .playing else { return false }
        state = .ready
        return true
    }

    private func upBitrateIfCanAfter(_ time: TimeInterval) {
        guard supportIncreamentalBitrate == true else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { [weak self] in
            guard let `self` = self else { return }
            guard self.player.timeControlStatus == .playing else { return }
            self.player.currentItem?.preferredPeakBitRate = self.preferredPeakBitRateForPlaying
        })
    }

    @objc func newErrorLogEntry(notification: Notification) {
        guard let object = notification.object, let playerItem = object as? AVPlayerItem else { return }
        guard let errorLog: AVPlayerItemErrorLog = playerItem.errorLog() else { return }
        
        if errorLog.description.contains("404") {
            state = .failed
        }
    }
    
    @objc func failedToPlayToEndTime(notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let error = userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error else { return }
        
        if error.localizedDescription.contains("404") {
            state = .failed
        }
    }
    
    @objc func playbackStalled(notification: Notification) {
        guard let isPlaybackBufferEmpty = player.currentItem?.isPlaybackBufferEmpty else { return }
        state = isPlaybackBufferEmpty ? .empty : .loading
    }
    
    @objc func playbackDidPlayToEndTime(notification: Notification) {
        state = .ready
    }
    
    private func playerItemPlaybackLikelyToKeepUpDidChange(_ playbackLikelyToKeepUp: Bool) {
        state = playbackLikelyToKeepUp ? .ready : .loading
    }
    
    private func playbackBufferEmptyDidChange(_ playbackBufferEmpty: Bool) {
        state = playbackBufferEmpty ? .empty : .loading
    }
    
    private func playerItemLoadedTimeRangesDidChange(_ loadedTimeRanges: [NSValue]) {
        guard
            let bufferedCMTime = loadedTimeRanges.first?.timeRangeValue.end,
            let bufferedTime = bufferedCMTime.timeInterval else { return }
        
        self.bufferedTime = bufferedTime
    }
}
