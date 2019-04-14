//
//  RegularPlayer.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import UIKit
import Foundation
import AVFoundation
import AVKit
import CoreMedia

/// A RegularPlayer is used to play regular videos.
open class RegularPlayer: NSObject, Player, ProvidesView {
    
    // MARK: Private Properties
    
    private var player = AVPlayer()
    
    // MARK: Public API
    
    /// Sets an AVAsset on the player.
    ///
    /// - Parameter asset: The AVAsset
    open func set(_ asset: AVAsset?) {
        removeCurrentItemIfExist()
        guard emptyPlayerIfAssetNotExist(asset) == false else { return }
        guard let asset = asset else { return }
        
        let playerItem = AVPlayerItem(asset: asset)
        addPlayerItemObservers(to: playerItem)
        player.replaceCurrentItem(with: playerItem)
        
        setBufferPreferenceToLow()
    }
    
    private func removeCurrentItemIfExist() {
        guard let currentItem = player.currentItem else { return }
        removePlayerItemObservers(from: currentItem)
    }
    
    private func emptyPlayerIfAssetNotExist(_ asset: AVAsset?) -> Bool {
        guard asset == nil else { return false }
        player.replaceCurrentItem(with: nil)
        return true
    }
    
    private func setBufferPreferenceToLow() {
        player.currentItem?.preferredPeakBitRate = preferredPeakBitRateForBegin
        player.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
    }
    
    // MARK: ProvidesView
    
    public let view: RegularPlayerView = RegularPlayerView(frame: .zero)
    private var regularPlayerView: RegularPlayerView { return view }
    private var playerLayer: AVPlayerLayer { return regularPlayerView.playerLayer }
    
    // MARK: Player
    
    weak public var delegate: PlayerDelegate?
    
    public var state: PlayerState = .ready {
        didSet { delegate?.playerDidUpdateState(player: self, previousState: oldValue) }
    }
    
    public var duration: TimeInterval {
        return player.currentItem?.duration.timeInterval ?? 0
    }
    
    public var time: TimeInterval = 0 {
        didSet { delegate?.playerDidUpdateTime(player: self) }
    }
    
    public var bufferedTime: TimeInterval = 0 {
        didSet { delegate?.playerDidUpdateBufferedTime(player: self) }
    }
    
    public var playing: Bool {
        return player.timeControlStatus == .playing
    }
    
    public var error: NSError? {
        return player.errorForPlayerOrItem
    }
    
    public var urlAsset: AVURLAsset? {
        return (player.currentItem?.asset) as? AVURLAsset
    }

    func getSeekTime(to time: TimeInterval) -> CMTime {
        return CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC))
    }
    
    // MARK: Control
    
    private var seeking: Bool = false
    public func seek(to time: TimeInterval) {
        guard seeking == false else { return }
        seeking = true
        
        player.seek(to: getSeekTime(to: time), completionHandler: { [weak self] (finished) -> Void in
            guard finished == true else { return }
            self?.seeking = false
            
            self?.time = time
        })
    }
    
    public func forceSeek(to time: TimeInterval) {
        player.seek(to: getSeekTime(to: time), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        self.time = time
        seeking = false
    }
    
    var userWantToPlay = false
    public func start() {
        guard readyToPlay() == true else { return }
        play()
    }
    
    public func readyToPlay() -> Bool {
        userWantToPlay = true
        
        prepareToPlay()
        return true
    }
    
    private func prepareToPlay() {
        startTimer()
        
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        player.currentItem?.preferredForwardBufferDuration = TimeInterval(0)
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func stop() {
        guard readyToStop() == true else { return }
        pause()
    }
    
    private func readyToStop() -> Bool {
        userWantToPlay = false
        
        prepareToStop()
        return true
    }
    
    private func prepareToStop() {
        timer = nil
        
        player.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
    }
    
    public func rewindIfNeeded() {
        guard time == duration else { return }
        seekToBegin()
    }
    private func seekToBegin() {
        forceSeek(to: TimeInterval(0))
    }
    
    // MARK: Lifecycle
    
    public override init() {
        super.init()
        
        addPlayerObservers()
        
        regularPlayerView.configureForPlayer(player: self.player)
        
        automaticallyWaitsToMinimizeStalling = false
    }
    
    deinit {
        timer = nil
        
        if let playerItem = player.currentItem {
            removePlayerItemObservers(from: playerItem)
        }
        removePlayerObservers()
    }
    
    // MARK: Setup
    
    public var timeUpdateInterval: TimeInterval = 1.0
    
    public var timerInterval: TimeInterval = 3.0
    public var assetFailedReloadTimeout: TimeInterval = 10.0
    public var assetEmptyTimeout: TimeInterval = 5.0
    public var assetEmptyReloadTimeout: TimeInterval = 10.0
    public var assetLoadingTimeout: TimeInterval = 5.0
    public var assetLoadingReloadTimeout: TimeInterval = 10.0
    
    public var preferredPeakBitRateForBegin: Double = 1000
    public var preferredPeakBitRateForPlaying: Double = 1024 * 1024 * 4
    
    public var supportIncreamentalBitrate: Bool = true

    public var usesExternalPlaybackWhileExternalScreenIsActive: Bool = true {
        didSet {
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
        }
    }

    public var automaticallyWaitsToMinimizeStalling: Bool = true {
        didSet {
            player.automaticallyWaitsToMinimizeStalling = automaticallyWaitsToMinimizeStalling
        }
    }
    
    // MARK: Observers
    
    var playerTimeObserver: Any?
    
    // MARK: Autrestart
    
    var autoRestartLoadCount: Int = 0
    var autoRestartEmptyCount: Int = 0
    var autoRestartFailedCount: Int = 0
    
    private func startTimer() {
        timer = Timer(timeInterval: timerInterval, target: self, selector: #selector(on(timer:)), userInfo: nil, repeats: true)
    }
    
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
            guard let timer: Timer = timer else { return }
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    // MARK: Capability Protocol Helpers
    
    #if os(iOS)
    public lazy var _pictureInPictureController: AVPictureInPictureController? = {
        AVPictureInPictureController(playerLayer: regularPlayerView.playerLayer)
    }()
    #endif
}

public class RegularPlayerView: UIView {
    var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
    override public class var layerClass: AnyClass { return AVPlayerLayer.self }
    
    func configureForPlayer(player: AVPlayer) {
        (layer as? AVPlayerLayer)?.player = player
    }
}

// MARK: Auto Restart

extension RegularPlayer {
    
    @objc func on(timer: Timer) {
        guard userWantToPlay == true else { return }
        
        switch state {
            
        case .empty:  // Might network fail. if live streaming, chunk might created yet
            // If live streaming chunk exist, will play chunk
            autoRestartEmptyCount += Int(timer.timeInterval)
            
        case .loading:  // loading or network is slow
            // couldnt play after reconnect live
            autoRestartLoadCount += Int(timer.timeInterval)
            break
            
        case .ready:  // normal
            resetAllAutoRestartCount()
            
        case .failed:  // fail to play or file not found 404
            autoRestartFailedCount += Int(timer.timeInterval)
            
        default:  // unknown
            break
        }
        
        if
            autoRestartFailedCount > Int(assetFailedReloadTimeout) ||
                autoRestartEmptyCount > Int(assetEmptyReloadTimeout) ||
                autoRestartLoadCount > Int(assetLoadingReloadTimeout) {  // Need to reset
            
            resetAllAutoRestartCount()
            guard retrySetIfCan() == true else { return }
            play()

        } else if autoRestartEmptyCount > Int(assetEmptyTimeout) || autoRestartLoadCount > Int(assetLoadingTimeout) {  // try to play
            
            resetAllAutoRestartCount()
            retryPlayIfNeeded()
        }
    }
    
    private func retrySetIfCan() -> Bool {
        guard let asset: AVAsset = player.currentItem?.asset else { return false }
        set(asset)
        return true
    }
    private func retryPlayIfNeeded() {
        guard player.timeControlStatus != .playing else { return }
        play()
    }
    
    private func resetAllAutoRestartCount() {
        autoRestartFailedCount = 0
        autoRestartEmptyCount = 0
        autoRestartLoadCount = 0
    }
}

// MARK: Observer

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

// MARK: Capability Protocols

extension RegularPlayer: AirPlayCapable {
    public var isAirPlayEnabled: Bool {
        get { return player.allowsExternalPlayback }
        set { return player.allowsExternalPlayback = newValue }
    }
}

#if os(iOS)
extension RegularPlayer: PictureInPictureCapable {
    public var pictureInPictureController: AVPictureInPictureController? {
        return _pictureInPictureController
    }
}
#endif

extension RegularPlayer: VolumeCapable {
    public var volume: Float {
        get { return player.volume }
        set { player.volume = newValue }
    }
}

extension RegularPlayer: FillModeCapable {
    public var fillMode: FillMode {
        get {
            let gravity = (view.layer as? AVPlayerLayer)?.videoGravity
            return getFillMode(by: gravity)
        }
        set (newValue) {
            let gravity = getVideoGravity(by: newValue)
            (view.layer as? AVPlayerLayer)?.videoGravity = gravity
        }
    }
    
    private func getFillMode(by gravity: AVLayerVideoGravity?) -> FillMode {
        return gravity == .resizeAspect ? .fit : .fill
    }
    private func getVideoGravity(by fillMode: FillMode) -> AVLayerVideoGravity {
        switch fillMode {
        case .fit: return .resizeAspect
        case .fill: return .resizeAspectFill
        }
    }
}

extension RegularPlayer: TextTrackCapable {
    
    public var selectedTextTrack: TextTrackMetadata? {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return nil }
        return player.currentItem?.currentMediaSelection.selectedMediaOption(in: group)
    }
    
    public var availableTextTracks: [TextTrackMetadata] {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return [] }
        return group.options
    }
    
    public func fetchTextTracks(completion: @escaping ([TextTrackMetadata], TextTrackMetadata?) -> Void) {
        player.currentItem?.asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.availableMediaCharacteristicsWithMediaSelectionOptions)]) { [weak self] in
            guard
                let `self` = self,
                let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
                    completion([], nil)
                    return
            }
            completion(group.options, self.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group))
        }
    }
    
    public func select(_ textTrack: TextTrackMetadata?) {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
        guard let track = textTrack else {
            player.currentItem?.select(nil, in: group)
            return
        }
        
        let option = group.options.first(where: { option in
            track.matches(option)
        })
        player.currentItem?.select(option, in: group)
    }
}

extension AVMediaSelectionOption: TextTrackMetadata {
    public var isSDHTrack: Bool {
        return hasMediaCharacteristic(.describesMusicAndSoundForAccessibility) && hasMediaCharacteristic(.transcribesSpokenDialogForAccessibility)
    }
}
