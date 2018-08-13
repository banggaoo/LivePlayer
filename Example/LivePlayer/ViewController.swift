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

class ViewController: UIViewController
{
   
    @IBAction func singleButton(_ sender: Any) {
        
        let playerViewController: PlayerViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        playerViewController.delegate = self

        playerViewController.videoURL = URL(string: "https://wowzaprod179-i.akamaihd.net/hls/live/678082/1b11010a/playlist.m3u8")!
        
        self.present(playerViewController, animated: true, completion: nil)
    }
    
    @IBAction func infiniteButton(_ sender: Any) {
 
         let lives: LivesModel = LivesModel()
         
         lives.media = [LiveModel]()
        
        let liveList1: LiveModel = LiveModel()
        liveList1.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
        liveList1.subject = "First"
        
        lives.media?.append(liveList1)
        
        let liveList2: LiveModel = LiveModel()
        liveList2.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
        liveList2.subject = "Second"
        
        lives.media?.append(liveList2)
        
        let liveList3: LiveModel = LiveModel()
        liveList3.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
        liveList3.subject = "Third"
        
        lives.media?.append(liveList3)
        
        let liveList4: LiveModel = LiveModel()
        liveList4.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
        liveList4.subject = "Fourth"
        
        lives.media?.append(liveList4)
        
        let liveList5: LiveModel = LiveModel()
        liveList5.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
        liveList5.subject = "Fifth"
        
        lives.media?.append(liveList5)
        
        let liveList6: LiveModel = LiveModel()
        liveList6.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
        liveList6.subject = "Sixth"
        
        lives.media?.append(liveList6)
 
        let playerScrollViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerScrollViewController") as! PlayerScrollViewController
        
        playerScrollViewController.viewModel.list = lives.media
        playerScrollViewController.viewModel.index = 0
        
        self.present(playerScrollViewController, animated: true, completion: nil)
    }
 
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient,
                                                         mode: AVAudioSessionModeMoviePlayback,
                                                         options: [.mixWithOthers])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
}

extension ViewController: PlayerViewDelegate {
    
    @objc func didTapExitButton() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapPlayButton(_ player: RegularPlayer) {
        
    }
}
