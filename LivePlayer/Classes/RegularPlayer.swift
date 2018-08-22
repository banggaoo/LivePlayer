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

extension AVMediaSelectionOption: TextTrackMetadata
{
    public var isSDHTrack: Bool
    {
        return self.hasMediaCharacteristic(.describesMusicAndSoundForAccessibility) && self.hasMediaCharacteristic(.transcribesSpokenDialogForAccessibility)
    }
}

/// A RegularPlayer is used to play regular videos.
@objc open class RegularPlayer: NSObject, Player, ProvidesView
{
    public struct Constants
    {
        public static let TimeUpdateInterval: TimeInterval = 0.1
    }
    
    // MARK: Private Properties
    
    public var player = AVPlayer()
        
    // MARK: Public API
    
    /// Sets an AVAsset on the player.
    ///
    /// - Parameter asset: The AVAsset
    @objc open func set(_ asset: AVAsset)
    {
        // Prepare the old item for removal
        
        if let currentItem = self.player.currentItem
        {
            self.removePlayerItemObservers(fromPlayerItem: currentItem)
        }
        
        // Replace it with the new item
        
        let playerItem = AVPlayerItem(asset: asset)
        
        self.addPlayerItemObservers(toPlayerItem: playerItem)
        
        self.player.replaceCurrentItem(with: playerItem)
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
        return self.player.rate > 0
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
    
    var autoRestartCount: Int = 0

    private var timer: Timer? {
        didSet {
            oldValue?.invalidate()
            if let timer: Timer = timer {
                RunLoop.main.add(timer, forMode: .commonModes)
            }
        }
    }

    public func seek(to time: TimeInterval)
    {
        guard refreshFlag else { return }
        
        refreshFlag = false
        self.player.seek(to: getSeekTime(to: time), completionHandler: { [weak self] (isFinished:Bool) -> Void in
            
            self?.refreshFlag = true
        })
        
        self.time = time
    }
    
    public func forceSeek(to time: TimeInterval)
    {
        self.player.seek(to: getSeekTime(to: time), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)

        self.time = time
    }
    
    public func play()
    {
        
        timer = Timer(timeInterval: 3.0, target: self, selector: #selector(on(timer:)), userInfo: nil, repeats: true)

        self.player.play()
    }
    
    public func pause()
    {
        
        timer = nil
        
        self.player.pause()
    }
    
    @objc private func on(timer: Timer) {
        // Check connection is need to retry
        
        if autoRestartCount > 5 {
            NSLog("autoRestartCount > 5")
            autoRestartCount = 1

            guard let asset: AVAsset = self.player.currentItem?.asset else { return }
            
            set(asset)
            return
        }
        
        if autoRestartCount > 0 {
            NSLog("autoRestartCount > 0")

            autoRestartCount += 1
            
            //if self.player.timeControlStatus == .paused {
                self.player.playImmediately(atRate: 1.0)
            //}
        }
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
            if #available(iOS 10.0, *)
            {
                self.player.automaticallyWaitsToMinimizeStalling = automaticallyWaitsToMinimizeStalling
            }
        }
    }
    
    var playerTimeObserver: Any?

    // MARK: Capability Protocol Helpers
    
    #if os(iOS)
    @available(iOS 9.0, *)
    public lazy var _pictureInPictureController: AVPictureInPictureController? = {
        AVPictureInPictureController(playerLayer: self.regularPlayerView.playerLayer)
    }()
    #endif
}

