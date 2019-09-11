//
//  AVPlayerScrollPageViewController.swift
//  LivePlayer_Example
//
//  Created by James Lee on 02/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AVKit

class AVPlayerView: UIView {
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }
    
    private var playerLayer: AVPlayerLayer {
        return self.layer as! AVPlayerLayer
    }
    
    func player() -> AVPlayer {
        return playerLayer.player!
    }
    
    func setPlayer(player: AVPlayer) {
        playerLayer.player = player
    }
    
    func setVideoFillMode(fillMode: String) {
        playerLayer.videoGravity = AVLayerVideoGravity(rawValue: fillMode)
    }
    
    func videoFillMode() -> String {
        return playerLayer.videoGravity.rawValue
    }
}

final class AVPlayerScrollPageViewController: UIViewController {
    private(set) var liveHashValue: Int?
    
    var index = 0
    
    private lazy var playerView: AVPlayerView = {
        let view = AVPlayerView()
        view.setPlayer(player: player)
        return view
    }()
    private lazy var player: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    // MARK: Interface
    
    func configure(live: LiveModel) {
        self.liveHashValue = live.hashValue
        configure(
            videoUrlStr: live.media_url)
    }
    private func configure(videoUrlStr: String?) {
        if
            let urlStr = videoUrlStr,
            let url = URL(string: urlStr) {
            let asset = AVAsset(url: url)
            let playerItem = AVPlayerItem(asset: asset)
            player.replaceCurrentItem(with: playerItem)
        }
    }
    
    func play() {
        print("Play")
        guard player.timeControlStatus != .playing else { return }
        player.play()
    }
    func rewindIfNeeded() {
//        playerController.rewindIfNeeded()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    private func setup() {
        view.addSubviewWithFullsize(playerView)
        
        player.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: nil)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new, .old], context: nil)
    }
    
    // MARK: Observation
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
        
        if keyPath == "status" {
            guard
                let statusInt = change?[.newKey] as? Int,
                let status = AVPlayer.Status(rawValue: statusInt) else { return }
            print(status)
//            playerStatusDidChange(status: status)
            
        } else if keyPath == "timeControlStatus" {
            guard
                let statusInt = change?[.newKey] as? Int,
                let status = AVPlayer.TimeControlStatus(rawValue: statusInt) else { return }
            print(status)
//            playerTimeControlStatusDidChange(status: status)
        }
    }
    
    private func observeAVPlayerItemValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "status" {
            guard
                let statusInt = change?[.newKey] as? Int,
                let status = AVPlayerItem.Status(rawValue: statusInt) else { return }
            print(status)
//            playerItemStatusDidChange(status: status)
            
//        } else if keyPath == RegularPlayer.KeyPath.PlayerItem.PlaybackLikelyToKeepUp {
//            guard let playbackLikelyToKeepUp = change?[.newKey] as? Bool else { return }
//            playerItemPlaybackLikelyToKeepUpDidChange(playbackLikelyToKeepUp)
//            
//        } else if keyPath == RegularPlayer.KeyPath.PlayerItem.LoadedTimeRanges {
//            guard let loadedTimeRanges = change?[.newKey] as? [NSValue] else { return }
//            playerItemLoadedTimeRangesDidChange(loadedTimeRanges)
//            
//        } else if keyPath == RegularPlayer.KeyPath.PlayerItem.PlaybackBufferEmpty {
//            guard let playbackBufferEmpty = change?[.newKey] as? Bool else { return }
//            playbackBufferEmptyDidChange(playbackBufferEmpty)
        }
    }

}
