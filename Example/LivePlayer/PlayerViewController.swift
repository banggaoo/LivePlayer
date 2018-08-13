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

@objc public protocol PlayerViewDelegate {

    @objc func didTapExitButton()
    @objc func didTapPlayButton(_ player: RegularPlayer)
}

class PlayerViewController: UIViewController, PlayerDelegate {

    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    private let player = RegularPlayer()

    public weak var delegate: PlayerViewDelegate?

    public var index: Int = 0

    public var _videoURL: URL? = URL(string: "")
    public var videoURL: URL? {

        get { return _videoURL }

        set {

            guard _videoURL?.absoluteString != newValue?.absoluteString else { return }

            _videoURL = newValue

            print("self.player.set \(_videoURL)")
            self.player.set(AVURLAsset(url: _videoURL!))
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.player.play()
        //self.player.player.playImmediately(atRate: 1.0)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.player.pause()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

    }

    // MARK: Setup

    private func setup() {

        player.delegate = self
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
    }

    // MARK: Actions

    @IBAction func didTapPlayButton() {

        delegate?.didTapPlayButton(self.player)

        self.player.playing ? self.player.pause() : self.player.play()
    }

    @IBAction func didTapExitButton() {

        delegate?.didTapExitButton()
    }

    private func getSeekTimeInterval() -> TimeInterval {

        return Double(self.slider.value) * self.player.duration
    }

    @IBAction func didChangeSliderValue() {
        self.player.seek(to: getSeekTimeInterval())
    }

    @IBAction func didFinishSliderValue() {
        self.player.forceSeek(to: getSeekTimeInterval())
    }

    // MARK: VideoPlayerDelegate

    func playerDidUpdateState(player: Player, previousState: PlayerState) {
        self.activityIndicator.isHidden = true

        switch player.state {
        case .loading:

            self.activityIndicator.isHidden = false

        case .ready:

            break

        case .failed:

            NSLog("🚫 \(String(describing: player.error))")
        }
    }

    func playerDidUpdatePlaying(player: Player) {
        self.playButton.isSelected = player.playing
    }

    func playerDidUpdateTime(player: Player) {
        guard player.duration > 0 else {
            return
        }

        let ratio = player.time / player.duration

        if self.slider.isHighlighted == false {
            self.slider.value = Float(ratio)
        }
    }

    func playerDidUpdateBufferedTime(player: Player) {

        guard player.duration > 0 else { return }

        let ratio = Int((player.bufferedTime / player.duration) * 100)

        self.label.text = "Buffer: \(ratio)%"
    }
}
 
