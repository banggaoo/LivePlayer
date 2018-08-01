//
//  ViewController.swift
//  LivePlayer
//
//  Created by banggaoo on 08/01/2018.
//  Copyright (c) 2018 banggaoo. All rights reserved.
//

import UIKit
import LivePlayer
import AVFoundation

class ViewController: UIViewController, PlayerDelegate
{
    private struct Constants
    {
        static let VideoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let player = RegularPlayer()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        player.delegate = self
        
        self.addPlayerToView()
        
        self.player.set(AVURLAsset(url: Constants.VideoURL))
    }
    
    // MARK: Setup
    
    private func addPlayerToView()
    {
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.view.frame = self.view.bounds
        self.view.insertSubview(player.view, at: 0)
    }
    
    // MARK: Actions
    
    @IBAction func didTapPlayButton()
    {
        self.player.playing ? self.player.pause() : self.player.play()
    }
    
    private func getSeekTimeInterval() -> TimeInterval {
        
        return Double(self.slider.value) * self.player.duration
    }
    
    @IBAction func didChangeSliderValue()
    {
        self.player.seek(to: getSeekTimeInterval())
    }
    
    @IBAction func didFinishSliderValue()
    {
        self.player.forceSeek(to: getSeekTimeInterval())
    }
    
    // MARK: VideoPlayerDelegate
    
    func playerDidUpdateState(player: Player, previousState: PlayerState)
    {
        self.activityIndicator.isHidden = true
        
        switch player.state
        {
        case .loading:
            
            self.activityIndicator.isHidden = false
            
        case .ready:
            
            break
            
        case .failed:
            
            NSLog("🚫 \(String(describing: player.error))")
        }
    }
    
    func playerDidUpdatePlaying(player: Player)
    {
        self.playButton.isSelected = player.playing
    }
    
    func playerDidUpdateTime(player: Player)
    {
        guard player.duration > 0 else
        {
            return
        }
        
        let ratio = player.time / player.duration
        
        if self.slider.isHighlighted == false
        {
            self.slider.value = Float(ratio)
        }
    }
    
    func playerDidUpdateBufferedTime(player: Player)
    {
        guard player.duration > 0 else
        {
            return
        }
        
        let ratio = Int((player.bufferedTime / player.duration) * 100)
        
        self.label.text = "Buffer: \(ratio)%"
    }
}

open class CustomSlider : UISlider {
    
    @IBInspectable open var trackWidth: CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        let multiValue: Float = value - 0.5
        let pixelAdjustment: Float = 35.0
        let xOriginDelta: Float = multiValue * ( Float(bounds.size.width) - pixelAdjustment)
        
        return CGRect(
            x: bounds.origin.x + CGFloat(xOriginDelta),
            y: bounds.origin.y,
            width: bounds.size.width,
            height: bounds.size.height
        )
    }
}
