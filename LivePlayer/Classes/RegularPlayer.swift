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
@objc open class RegularPlayer: NSObject, Player, ProvidesView
{
   
    // MARK: Private Properties
    
    public var player = AVPlayer()
        
    // MARK: Public API
    
    /// Sets an AVAsset on the player.
    ///
    /// - Parameter asset: The AVAsset
    @objc open func set(_ asset: AVAsset?)
    {
        // Prepare the old item for removal
        
        if let currentItem = self.player.currentItem
        {
            self.removePlayerItemObservers(fromPlayerItem: currentItem)
        }
        
        // Replace it with the new item
        if let asset = asset {
            
            let playerItem = AVPlayerItem(asset: asset)
            
            self.addPlayerItemObservers(toPlayerItem: playerItem)
            
            self.player.replaceCurrentItem(with: playerItem)
            
            // set buffer prefence to low
            self.player.currentItem?.preferredPeakBitRate = 1000.0
            self.player.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
            self.player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false

        }else{
            
            self.player.replaceCurrentItem(with: nil)
        }
    }
    
    // MARK: ProvidesView
    
    private class RegularPlayerView: UIView
    {
        var playerLayer: AVPlayerLayer
        {
            return self.layer as! AVPlayerLayer
        }
        
        override class var layerClass: AnyClass
        {
            return AVPlayerLayer.self
        }
        
        func configureForPlayer(player: AVPlayer)
        {
            (self.layer as! AVPlayerLayer).player = player
        }
    }
    
    public let view: UIView = RegularPlayerView(frame: .zero)
    
    private var regularPlayerView: RegularPlayerView
    {
        return self.view as! RegularPlayerView
    }
    
    private var playerLayer: AVPlayerLayer
    {
        return self.regularPlayerView.playerLayer
    }
    
    // MARK: Player
    
    weak public var delegate: PlayerDelegate?
    
    public var state: PlayerState = .ready
    {
        didSet
        {
            self.delegate?.playerDidUpdateState(player: self, previousState: oldValue)
        }
    }
    
    public var duration: TimeInterval
    {
        return self.player.currentItem?.duration.timeInterval ?? 0
    }
    
    public var time: TimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateTime(player: self)
        }
    }
    
    public var bufferedTime: TimeInterval = 0
    {
        didSet
        {
            self.delegate?.playerDidUpdateBufferedTime(player: self)
        }
    }
    
    public var playing: Bool
    {
        return self.player.timeControlStatus == .playing
    }
    
    public var error: NSError?
    {
        return self.player.errorForPlayerOrItem
    }
    
    func getSeekTime(to time: TimeInterval) -> CMTime
    {
        return CMTimeMakeWithSeconds(time, Int32(NSEC_PER_SEC))
    }
    
    private var refreshFlag: Bool = true
    
    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
            if let timer: Timer = timer {
                RunLoop.main.add(timer, forMode: .commonModes)
            }
        }
    }

    public func seek(to time: TimeInterval) {
        guard refreshFlag else { return }
        refreshFlag = false
        
        self.player.seek(to: getSeekTime(to: time), completionHandler: { [weak self] (isFinished: Bool) -> Void in
            
            if isFinished {
            
                self?.refreshFlag = true
                
                self?.time = time
            }
        })
        
        self.time = time
    }
    
    public func forceSeek(to time: TimeInterval) {
        
        self.player.seek(to: getSeekTime(to: time), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)

        self.time = time
    }
    
    var userWantToPlay = false

    public func start() {
        guard userWantToPlay == false else { return }
    
        prepare()
        play()
    }
    
    public func prepare() {
        
        userWantToPlay = true
        
        timer = Timer(timeInterval: RegularPlayerConstants.TimerInterval, target: self, selector: #selector(on(timer:)), userInfo: nil, repeats: true)
   
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
        player.currentItem?.preferredForwardBufferDuration = TimeInterval(0)
    }

    public func play() {
        
        player.play()
    }
    
    public func pause() {

        player.currentItem?.preferredForwardBufferDuration = TimeInterval(1)
        player.currentItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = false

        player.currentItem?.cancelPendingSeeks()
        player.currentItem?.asset.cancelLoading()

        player.pause()
    }
    
    public func stop() {
        guard userWantToPlay == true else { return }
        userWantToPlay = false
        
        timer = nil

        pause()
    }
    
    // MARK: Lifecycle
    
    public override init()
    {
        super.init()
        
        self.addPlayerObservers()
        
        self.regularPlayerView.configureForPlayer(player: self.player)
        
        self.setupAirplay()
        
        self.automaticallyWaitsToMinimizeStalling = false
    }
    
    deinit
    {
        timer = nil

        if let playerItem = self.player.currentItem
        {
            self.removePlayerItemObservers(fromPlayerItem: playerItem)
        }
        
        self.removePlayerObservers()
    }
    
    // MARK: Setup
    
    private func setupAirplay()
    {
        self.player.usesExternalPlaybackWhileExternalScreenIsActive = true
    }
    
    public var automaticallyWaitsToMinimizeStalling: Bool = true
    {
        didSet
        {
            self.player.automaticallyWaitsToMinimizeStalling = automaticallyWaitsToMinimizeStalling
        }
    }
    
    // MARK: Observers

    var playerTimeObserver: Any?

    // MARK: Autrestart
    
    var autoRestartCount: Int = 0

    // MARK: Capability Protocol Helpers
    
    #if os(iOS)
    @available(iOS 9.0, *)
    public lazy var _pictureInPictureController: AVPictureInPictureController? = {
        AVPictureInPictureController(playerLayer: self.regularPlayerView.playerLayer)
    }()
    #endif
}

