//
//  PlayerController.swift
//  GDNY
//
//  Created by James Lee on 31/03/2019.
//  Copyright © 2019 st. All rights reserved.
//

import Foundation
import LivePlayer
import AVFoundation
import MediaPlayer

protocol PlayerControllerDelegate: class {
    func didChangePlayerState(_ state: PlayerController.PlayerState)
    func didFailedLoadBecause(_ state: PlayerController.FailedState)
    func didUpdateTimeControlStatus(_ playing: Bool)
    func playerDidUpdateTime(_ time: TimeInterval, _ duration: TimeInterval)
}

final class PlayerController {
    lazy var player: RegularPlayer = {
        let player = RegularPlayer()
        player.delegate = self
        player.setDefaultOption()
        return player
    }()
    
    weak var delegate: PlayerControllerDelegate?
    
    // MARK: Interface
    
    func prepare(isBackgroundPlayEnabled: Bool) {
        self.isBackgroundPlayEnabled = isBackgroundPlayEnabled
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        setupRemoteTransportControls()
    }
    
    func insertPlayerView(in superview: UIView) {
        player.view.removeFromSuperviewIfIn()
        
        player.view.frame = superview.bounds
        superview.addSubviewWithFullsize(player.view)
    }
    
    func start() {
        updateNowPlayingInfoIfNeeded()
        player.start()
        setMPRemoteCommandEnabled(true)
    }
    func play() {
        player.play()
    }
    func playIfNotBackgroundPlayable() {
        guard isBackgroundPlayEnabled == false else { return }
        play()
    }
    func pause() {
        player.pause()
    }
    func stop() {
        player.stop()
    }
    func stopIfNotBackgroundPlayable() {
        guard isBackgroundPlayEnabled == false else { return }
        stop()
    }
    func stopIfBackgroundPlaying() {
        guard isBackgroundPlayEnabled == true else { return }
        stop()
    }
    
    var playing: Bool {
        return player.playing
    }
    
    func rewindIfNeeded() {
        player.rewindIfNeeded()
    }
    func seek(value: Double) {
        player.seek(to: getSeekTimeInterval(value))
    }
    func forceSeek(value: Double) {
        player.forceSeek(to: getSeekTimeInterval(value))
    }
    
    var isHidden: Bool {
        get { return player.view.isHidden }
        set (newValue) { player.view.isHidden = newValue }
    }
    
    func loadVideo(with url: URL?, title: String? = nil, coverImageUrl: URL? = nil, channelId: Int? = nil, type: LiveModel.MediaType, published: Bool) {
        self.title = title
        self.coverImageUrl = coverImageUrl
        self.channelId = channelId
        mediaType = type
        
        guard checkIsPlayable(with: url, type, published) == true else {
            emptyPlayer()
            return
        }
        updatePlayerIfNeeded(with: url)
    }
    
    var isBackgroundPlayEnabled: Bool? {
        didSet {
            if isBackgroundPlayEnabled == true {
                UIApplication.shared.beginReceivingRemoteControlEvents()
                
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback,
                                                                 mode: .moviePlayback,
                                                                 options: [])
            } else {
                UIApplication.shared.endReceivingRemoteControlEvents()
                
                try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,
                                                                 mode: .moviePlayback,
                                                                 options: [.mixWithOthers])
                
                setMPRemoteCommandEnabled(false)
            }
            try? AVAudioSession.sharedInstance().setActive(true)
        }
    }
    
    var url: URL? {
        return player.urlAsset?.url
    }
    
    // MARK: Background Play
    
    @objc private func willEnterForeground() {
        guard isBackgroundPlayEnabled == true else {
            player.play()
            return
        }
        player.connectAVPlayerLayer()
    }
    
    @objc private func didEnterBackground() {
        guard isBackgroundPlayEnabled == true else { return }
        player.disconnectAVPlayerLayer()  // for keep playing while background mode
    }
    
    private func setupRemoteTransportControls() {
        guard isBackgroundPlayEnabled == true else { return }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget { [weak self] event in
            guard let `self` = self else { return .commandFailed }
            if self.player.playing == false {
                self.start()
                return .success
            }
            return .commandFailed
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            guard let `self` = self else { return .commandFailed }
            if self.player.playing == true {
                self.stop()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func updateNowPlayingInfoIfNeeded() {
        guard isBackgroundPlayEnabled == true else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        updateNowPlayingCoverImageIfCan()
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.time
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    private func updateNowPlayingCoverImageIfCan() {
        guard let coverImageUrl = coverImageUrl else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
//        ImageDownloader.default.downloadImage(with: coverImageUrl, options: [.downloadPriority(URLSessionTask.lowPriority)]) { result in
//            switch result {
//            case .success(let value):
//                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: value.image.size) { size in
//                    return value.image
//                }
//                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//            case .failure(let error):
//                printLog(error)
//            }
//        }
    }
    
    private func setMPRemoteCommandEnabled(_ isEnabled: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = isEnabled
        commandCenter.pauseCommand.isEnabled = isEnabled
    }
    
    // MARK: Lifecycle
    
    deinit {
        printLog("deinit")
        setMPRemoteCommandEnabled(false)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: State
    
    enum PlayerState {
        case undefined
        case loading
        case empty
        case ready
        case failed
    }
    
    enum FailedState {
        case ended
        case empty
    }
    
    // MARK: UI
    
    private var title: String?
    private var coverImageUrl: URL?
    private var channelId: Int?
    private var mediaType: LiveModel.MediaType?
    static private let waitingTime: TimeInterval = 2
    
    private func getSeekTimeInterval(_ value: Double) -> TimeInterval {
        return value * player.duration
    }
    
    private func checkIsPlayable(with url: URL?, _ type: LiveModel.MediaType, _ isPublished: Bool) -> Bool {
        guard isEndedLive(with: type, isPublished) == false else {
            delegate?.didFailedLoadBecause(.ended)
            return false
        }
        guard url != nil else {
            delegate?.didFailedLoadBecause(.empty)
            return false
        }
        return true
    }
    
    private func isEndedLive(with type: LiveModel.MediaType, _ isPublished: Bool) -> Bool {
        guard type == .live, isPublished == false else { return false }
        return true
    }
    
    private func emptyPlayer() {
        player.set(nil)
    }
    
    private func updatePlayerIfNeeded(with url: URL?) {
        guard isNeedUpdate(with: url) == true else { return }
        updatePlayer(with: url)
    }
    private func updatePlayer(with url: URL?) {
        guard let url = url else { return }
        player.set(AVURLAsset(url: url))
    }
    
    private func isNeedUpdate(with url: URL?) -> Bool {
        return url != self.url
    }
}

extension PlayerController: PlayerDelegate {
    
    func playerDidUpdateState(player: Player, previousState: LivePlayer.PlayerState) {
        guard player.state != previousState else { return }
        
        switch player.state {
            
        case .loading:  // loading or network is slow
            changeLoadingState(waitUntil: PlayerController.waitingTime)
        case .ready:
            delegate?.didChangePlayerState(.ready)
            
        case .empty:  // Might network fail. if live streaming, chunk might created yet
            changeEmptyState(waitUntil: PlayerController.waitingTime)
            checkBroadcastStateIfCan()
        case .failed:  // fail to play or file not found 404
            delegate?.didChangePlayerState(.failed)
            checkBroadcastStateIfCan()
        case .unknown:
            break
        }
    }
    
    func playerDidUpdateTimeControlStatus(player: Player) {
        delegate?.didUpdateTimeControlStatus(player.playing)
    }
    
    func playerDidUpdateTime(player: Player) {
        delegate?.playerDidUpdateTime(player.time, player.duration)
    }
    func playerDidUpdateBufferedTime(player: Player) {
    }
    
    private func checkBroadcastStateIfCan() {
        guard mediaType == .live else { return }
        checkBroadcastState(waitUntil: PlayerController.waitingTime)
    }
    
    private func changeLoadingState(waitUntil: TimeInterval) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + waitUntil, execute: { [weak self] in
            guard let self = self else { return }
            guard self.player.state == .loading, self.playing == false else { return }
            
            self.delegate?.didChangePlayerState(.loading)
        })
    }
    private func changeEmptyState(waitUntil: TimeInterval) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + waitUntil, execute: { [weak self] in
            guard let self = self else { return }
            guard self.player.state == .empty, self.playing == false else { return }
            
            self.delegate?.didChangePlayerState(.empty)
        })
    }
    
    private func checkBroadcastState(waitUntil: TimeInterval) {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + waitUntil, execute: { [weak self] in
            guard let self = self else { return }
            guard self.player.state == .empty || self.player.state == .failed else { return }
            guard self.playing == false else { return }
            
//            self.checkBroadcastState()
        })
    }
    /*
    private func checkBroadcastState() {
        guard let id = channelId else { return }
        
        _ = NetworkManager.shared.requestBroadcastChannelInfo(id, handler: { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let value):
                guard let channel = value.live_channel else { return }
                self.delegate?.didUpdateLiveChannelInfo(channel)
                self.handleChannelResult(channel)
                
            case .failure(let error):
                printLog(error)
                self.delegate?.didChangePlayerState(.failed)
            }
        })
    }
    private func handleChannelResult(_ channel: LiveChannelModel) {
        guard channel.isPublished == true else {
            delegate?.didFailedLoadBecause(.ended)
            player.stop()
            return
        }
        
        if player.state == .empty {
            delegate?.didChangePlayerState(.empty)
            player.stop()
            
        } else if player.state == .failed {
            delegate?.didChangePlayerState(.failed)
        }
    }*/
}
