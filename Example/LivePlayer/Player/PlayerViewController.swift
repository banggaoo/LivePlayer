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

class PlayerViewController: BasePlayerViewController {
    private let viewModel: PlayerViewModel
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        insertPlayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadVideo()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        player.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
 
        player.stop()
    }

    // MARK: Setup
    
    private func insertPlayer() {
        view.insertSubview(player.view, at: 0)
    }
    
    private var urlAsset: AVURLAsset? {
        return (player.player.currentItem?.asset) as? AVURLAsset
    }
    
    private func loadVideo() {
        guard let url = viewModel.mediaUrl else {
            emptyPlayer()
            return
        }
        guard let urlAsset = urlAsset else {
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

    // MARK: Action
 
    @IBAction private func didTapPlayButton() {
        player.changePlayerActionByPlaying()
    }

    @IBAction private func didTapExitButton() {
        dismiss(animated: true, completion: nil)
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
}

extension PlayerViewController: PlayerDelegate {
    
    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        printLog("playerDidUpdateState \(player.state)")
        statusLabel.text = "\(player.state)"

        switch player.state {
        case .loading:
            activityIndicator.isHidden = false
            
        case .failed:
            printLog("🚫 \(String(describing: player.error))")
            activityIndicator.isHidden = true

        default:
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

