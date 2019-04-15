//
//  PlayerViewController.swift
//  GDNY
//
//  Created by st on 03/08/2018.
//  Copyright © 2018 st. All rights reserved.
//

import UIKit
import LivePlayer
import AVFoundation
import MediaPlayer

final class PlayerViewController: BasePlayerViewController {
    private let viewModel: PlayerViewModel
    
    @IBOutlet private weak var exitButton: UIButton!
    @IBOutlet private weak var playButton: UIButton!
    @IBOutlet private weak var slider: UISlider!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    lazy private var player: RegularPlayer = {
        let player = RegularPlayer()
        player.delegate = self
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = view.bounds
        return player
    }()
    
    init(with live: LiveModel) {
        viewModel = PlayerViewModel(with: live)

        super.init(nibName: type(of: self).className, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        printLog("PlayerViewController deinit")
        setMPRemoteCommandEnabled(false)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard isBackgroundPlayEnabled == false else { return }
        start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard isBackgroundPlayEnabled == false else { return }
        stop()
    }

    // MARK: Setup
    
    private func prepare() {
        
        insertPlayer()
        
        addUIApplicationNoti()
        
        loadVideo()
        
        setupRemoteTransportControls()
        
        guard isBackgroundPlayEnabled == true else { return }
        start()
    }
    
    var isBackgroundPlayEnabled = false {
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

    private func insertPlayer() {
        view.insertSubview(player.view, at: 0)
    }
    
    private func addUIApplicationNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    private func loadVideo() {
        guard let url = viewModel.mediaUrl else {
            emptyPlayer()
            return
        }
        guard let urlAsset = player.urlAsset else {
            updatePlayerAsset(by: url)
            return
        }
        updatePlayerIfUrlNotSame(before: urlAsset.url, after: url)
    }
    
    private func updatePlayerIfUrlNotSame(before: URL, after: URL) {
        guard before.absoluteString != after.absoluteString else { return }
        updatePlayerAsset(by: after)
    }
 
    private func updatePlayerAsset(by url: URL) {
        updatePlayerAsset(by: AVURLAsset(url: url))
    }
    private func updatePlayerAsset(by asset: AVURLAsset) {
        player.set(asset)
    }
    
    private func emptyPlayer() {
        player.set(nil)
    }
    
    // MARK: Control
    
    private func start() {
        updateNowPlayingInfoIfNeeded()
        player.start()
        setMPRemoteCommandEnabled(true)
    }
    private func stop() {
        player.stop()
    }
    
    // MARK: Action
 
    @IBAction private func didTapPlayButton() {
        changePlayerActionByPlaying()
    }
    private func changePlayerActionByPlaying() {
        player.playing ? stop() : start()
    }
    
    @IBAction private func didTapExitButton() {
        close()
    }
    private func close() {
        stopIfBackgroundPlaying()
        
        dismiss(animated: true, completion: nil)
    }
    private func stopIfBackgroundPlaying() {
        guard isBackgroundPlayEnabled == true else { return }
        player.stop()
    }

    @IBAction private func didChangeSliderValue() {
        player.seek(to: seekTime)
    }

    @IBAction private func didFinishSliderValue() {
        player.forceSeek(to: seekTime)
    }
    
    private var seekTime: TimeInterval {
        return Double(slider.value) * player.duration
    }
 
    // MARK: Background Play
    
    @objc func didBecomeActive() {
        guard isBackgroundPlayEnabled == true else { return }
        player.connectAVPlayerLayer()
    }
    
    @objc func didEnterBackground() {
        guard isBackgroundPlayEnabled == true else { return }
        player.disconnectAVPlayerLayer()
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
    
    private func setMPRemoteCommandEnabled(_ isEnabled: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = isEnabled
        commandCenter.pauseCommand.isEnabled = isEnabled
    }
    
    private func updateNowPlayingInfoIfNeeded() {
        guard isBackgroundPlayEnabled == true else { return }
        
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = viewModel.title
        
        if let imageName = viewModel.coverImageName, let image = UIImage(named: imageName) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.time
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}

extension PlayerViewController: PlayerDelegate {
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        statusLabel.text = "\(player.state)"

        switch player.state {
        case .loading:
            activityIndicator.isHidden = false
            
        case .failed, .empty:
            printLog("🚫 \(String(describing: player.error))")
            activityIndicator.isHidden = true

        default:  // .ready, .unknown
            activityIndicator.isHidden = true
        }
    }
    
    func playerDidUpdateTimeControlStatus(player: Player) {
        playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else { return }
        guard slider.isHighlighted == false else { return }
        let ratio = player.time / player.duration
        slider.value = Float(ratio)
    }
    
    func playerDidUpdateBufferedTime(player: Player) {
        guard player.duration > 0 else { return }
        let ratio = Int((player.bufferedTime / player.duration) * 100)
        label.text = "Buffer: \(ratio)%"
    }
}

