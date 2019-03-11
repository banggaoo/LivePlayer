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

class ViewController: UIViewController {
    //https://wowzaprod114-i.akamaihd.net/hls/live/678947/92320d61_1_1728/chunklist.m3u8
    //https://wowzaprod114-i.akamaihd.net/hls/live/678947/92320d61_1_1728/3ngjunba/00000000/media_11495.ts
    
    //https://wowzaprod179-i.akamaihd.net/hls/live/678082/1b11010a_1_448/yexg10yo/00000000/media_61.ts
    //https://wowzaprod114-i.akamaihd.net/hls/live/678947/92320d61_1_1728/3ngjunba/00000000/media_11495.ts

    @IBAction func singleButton(_ sender: Any) {
        
        let playerViewController: PlayerViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        playerViewController.delegate = self

        playerViewController.videoURL = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
        
        self.present(playerViewController, animated: true, completion: nil)
    }
    
    /*
     {"media":[{"id":514,"code_name":"유·초등","subject":"","media_url":"https://wowzaprod115-i.akamaihd.net/hls/live/689329/9d5dee97/playlist.m3u8","thumbnail_url":null,"premium":false,"screen_direction":"horizontal","likes_count":0,"bookmarks_count":0,"media_type":"live","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":0,"live_channel":{"id":387,"live_stream_id":"qwhz31vn","live_stream_name":"conects-mobile-1535073945-HYBXCFWD","primary_input":"rtmp://c3d23a.entrypoint.cloud.wowza.com/app-55af","stream_name":"c93234a7","user_name":"client33541","password":"7cfe8c6e","hls_playback_url":"","workflow_state":"published","rocket_chat_room_id":"a76p87az6ANycYRAq","rocket_chat_room_name":"Yz2yXwoMuGqBxyNAx_DTNMSLOY_1535073949","publish_channels":[],"medium_id":514,"recording_id":""}},{"id":513,"code_name":"유·초등","subject":"방가70","media_url":"https://wowzaprod114-i.akamaihd.net/hls/live/678947/c10a05e8/playlist.m3u8","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"live","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":0,"live_channel":{"id":386,"live_stream_id":"bj3bsf7j","live_stream_name":"conects-mobile-1535073603-HYJCMRQT","primary_input":"rtmp://d9fda0.entrypoint.cloud.wowza.com/app-741e","stream_name":"419f90f5","user_name":"client33541","password":"48427fb0","hls_playback_url":"","workflow_state":"published","rocket_chat_room_id":"4D42ZqB6xn58j5tfR","rocket_chat_room_name":"Yz2yXwoMuGqBxyNAx_UPERFXWJ_1535073606","publish_channels":[],"medium_id":513,"recording_id":""}},{"id":486,"code_name":"유·초등","subject":"방가62","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1930310/2152314_5bef8309.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":34,"bookmarks_count":0,"media_type":"vod","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":27,"live_channel":null},{"id":474,"code_name":"유·초등","subject":"방가58","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1923977/2145608_6e93916f.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"horizontal","likes_count":3,"bookmarks_count":0,"media_type":"vod","owner":{"id":8,"nickname":"OverholdYPCOTZLS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":6,"live_channel":null},{"id":471,"code_name":"유·초등","subject":"방가56","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1922162/2144008_cf35c7a2.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"horizontal","likes_count":2,"bookmarks_count":0,"media_type":"vod","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":5,"live_channel":null},{"id":469,"code_name":"유·초등","subject":"방가58","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1922579/2144644_ad51396c.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":5,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":5,"live_channel":null},{"id":464,"code_name":"유·초등","subject":"방가56","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1922022/2143863_ee4b3576.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":2,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":5,"live_channel":null},{"id":462,"code_name":"유·초등","subject":"방가56","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1921924/2143711_12a8d96d.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":1,"live_channel":null},{"id":460,"code_name":"유·초등","subject":"방가55","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1921875/2143623_02f3ca05.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":1,"live_channel":null},{"id":457,"code_name":"유·초등","subject":"방가54","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1921795/2143519_1fb6bc0c.0.mp4","thumbnail_url":null,"premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":0,"live_channel":null}],"meta":{"current_page":1,"next_page":2,"prev_page":0,"total_page":11,"total_count":103,"status":"ok","alert_type":0,"alert_message":""}}

    */
    @IBAction func infiniteButton(_ sender: Any) {
 
         let lives: LivesModel = LivesModel()
         
         lives.media = [LiveModel]()
        
        let liveList1: LiveModel = LiveModel()
        liveList1.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
        liveList1.subject = "First"
        
        lives.media?.append(liveList1)
        
        let liveList2: LiveModel = LiveModel()
        liveList2.media_url = "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8"
        liveList2.subject = "Second"
        
        lives.media?.append(liveList2)
        
        let liveList3: LiveModel = LiveModel()
        liveList3.media_url = "https://c2c-gdny-media-live.conects.com/transcoder_1970375/2194422_c96e7048.0.mp4"
        liveList3.subject = "Third"
        
        lives.media?.append(liveList3)
        
        let liveList4: LiveModel = LiveModel()
        liveList4.media_url = "https://c2c-gdny-media-live.conects.com/transcoder_1970005/2193997_6f846099.0.mp4"
        liveList4.subject = "Fourth"
        
        lives.media?.append(liveList4)
        
        let liveList5: LiveModel = LiveModel()
        liveList5.media_url = "https://c2c-gdny-media-live.conects.com/transcoder_1922162/2144008_cf35c7a2.0.mp4"
        liveList5.subject = "Fifth"
        
        lives.media?.append(liveList5)
        
        let liveList6: LiveModel = LiveModel()
        liveList6.media_url = "https://c2c-gdny-media-live.conects.com/transcoder_1922579/2144644_ad51396c.0.mp4"
        liveList6.subject = "Sixth"
        
        lives.media?.append(liveList6)
 
        let playerScrollViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerScrollViewController") as! PlayerScrollViewController
        
        playerScrollViewController.viewModel.list = lives.media
        playerScrollViewController.currentIndex = 0
        
        self.present(playerScrollViewController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,
                                                         mode: AVAudioSession.Mode.moviePlayback,
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


/*

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

*/
