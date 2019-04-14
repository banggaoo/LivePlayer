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
    
    public var player = AVPlayer()
    
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
    
    func getSeekTime(to time: TimeInterval) -> CMTime {
        return CMTimeMakeWithSeconds(time, preferredTimescale: Int32(NSEC_PER_SEC))
    }
    
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
            guard let timer: Timer = timer else { return }
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    // MARK: Setting
    
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

    // MARK: Control
    
    private var seeking: Bool = true
    public func seek(to time: TimeInterval) {
        guard seeking == false else { return }
        seeking = true
        
        player.seek(to: getSeekTime(to: time), completionHandler: { [weak self] (finished) -> Void in
            guard finished == true else { return }
            self?.seeking = false
            
            self?.time = time
        })
        self.time = time
    }
    
    public func forceSeek(to time: TimeInterval) {
        player.seek(to: getSeekTime(to: time), toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        self.time = time
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
    
    func prepareToPlay() {
        timer = Timer(timeInterval: timerInterval, target: self, selector: #selector(on(timer:)), userInfo: nil, repeats: true)
        
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
    
    func prepareToStop() {
        timer = nil
        
        player.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false
        
        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()
    }
    
    public func rewindIfNeeds() {
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

