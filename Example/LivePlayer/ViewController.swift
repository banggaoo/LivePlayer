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
   
    @IBAction func singleButton(_ sender: Any) {
        
        let playerViewController: PlayerViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        
        playerViewController.delegate = self

        playerViewController.videoURL = URL(string: "https://wowzaprod179-i.akamaihd.net/hls/live/678082/1b11010a/playlist.m3u8")!
        
        self.present(playerViewController, animated: true, completion: nil)
    }
    
    /*
    {"media":[{"id":487,"code_name":"유·초등","subject":"방가62 ","media_url":"https://wowzaprod115-i.akamaihd.net/hls/live/689329/b56e031b/playlist.m3u8","thumbnail_url":"https://cloud.wowza.com/proxy/thumbnail2/?target=13.124.121.63\u0026app=app-f4a7\u0026stream=a93d7fae\u0026fitMode=fitwidth\u0026width=360","premium":false,"screen_direction":"vertical","likes_count":1,"bookmarks_count":0,"media_type":"live","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":11,"live_channel":{"id":360,"live_stream_id":"dvdlrzhf","live_stream_name":"conects-mobile-1534991138-UZCQHFNP","primary_input":"rtmp://fe611a.entrypoint.cloud.wowza.com/app-f4a7","stream_name":"a93d7fae","user_name":"client33541","password":"1ec20c80","hls_playback_url":"","workflow_state":"published","rocket_chat_room_id":"ro2n9MaFQQagNhkep","rocket_chat_room_name":"Yz2yXwoMuGqBxyNAx_RJQCYXVA_1534991142","publish_channels":[],"medium_id":487,"recording_id":""}},{"id":486,"code_name":"유·초등","subject":"방가62","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1930310/2152314_5bef8309.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":1,"live_channel":null},{"id":480,"code_name":"유·초등","subject":"방가61","media_url":"https://wowzaprod114-i.akamaihd.net/hls/live/678947/92320d61/playlist.m3u8","thumbnail_url":"https://cloud.wowza.com/proxy/thumbnail2/?target=13.124.103.94\u0026app=app-7530\u0026stream=7c10c0f3\u0026fitMode=fitwidth\u0026width=360","premium":false,"screen_direction":"horizontal","likes_count":0,"bookmarks_count":0,"media_type":"live","owner":{"id":8,"nickname":"OverholdYPCOTZLS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":6,"live_channel":{"id":354,"live_stream_id":"ptfkdbys","live_stream_name":"conects-mobile-1534985321-YVLCFOAJ","primary_input":"rtmp://338a24.entrypoint.cloud.wowza.com/app-7530","stream_name":"7c10c0f3","user_name":"client33541","password":"1ac660a6","hls_playback_url":"","workflow_state":"published","rocket_chat_room_id":"MCPHG8KJS9gTp7HZD","rocket_chat_room_name":"AJWtm9nPjvjTrWoER_KBVMPDCO_1534985325","publish_channels":["xHJZTfuxFAXEgj3qR"],"medium_id":480,"recording_id":""}},{"id":474,"code_name":"유·초등","subject":"방가58","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1923977/2145608_6e93916f.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"horizontal","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":8,"nickname":"OverholdYPCOTZLS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":4,"live_channel":null},{"id":471,"code_name":"유·초등","subject":"방가56","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1922162/2144008_cf35c7a2.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"horizontal","likes_count":2,"bookmarks_count":0,"media_type":"vod","owner":{"id":18,"nickname":"StringtoughYNGODERJ","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":5,"live_channel":null},{"id":469,"code_name":"유·초등","subject":"방가58","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1922579/2144644_ad51396c.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":2,"live_channel":null},{"id":464,"code_name":"유·초등","subject":"방가56","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1922022/2143863_ee4b3576.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"vertical","likes_count":2,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":5,"live_channel":null},{"id":462,"code_name":"유·초등","subject":"방가56","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1921924/2143711_12a8d96d.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":1,"live_channel":null},{"id":460,"code_name":"유·초등","subject":"방가55","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1921875/2143623_02f3ca05.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":0,"live_channel":null},{"id":457,"code_name":"유·초등","subject":"방가54","media_url":"https://c2c-gdny-media-live.conects.com/transcoder_1921795/2143519_1fb6bc0c.0.mp4","thumbnail_url":"","premium":false,"screen_direction":"vertical","likes_count":0,"bookmarks_count":0,"media_type":"vod","owner":{"id":25,"nickname":"BamityBUERFQCS","avatar":""},"current_user_actions":{"bookmarked":false},"view_count":0,"live_channel":null}],"meta":{"current_page":1,"next_page":2,"prev_page":0,"total_page":11,"total_count":103,"status":"ok","alert_type":0,"alert_message":""}}

    */
    @IBAction func infiniteButton(_ sender: Any) {
 
         let lives: LivesModel = LivesModel()
         
         lives.media = [LiveModel]()
        
        let liveList1: LiveModel = LiveModel()
        liveList1.media_url = "https://wowzaprod115-i.akamaihd.net/hls/live/689413/3096ea4d/playlist.m3u8"
        liveList1.subject = "First"
        
        lives.media?.append(liveList1)
        
        let liveList2: LiveModel = LiveModel()
        liveList2.media_url = "https://c2c-gdny-media-live.conects.com/transcoder_1930310/2152314_5bef8309.0.mp4"
        liveList2.subject = "Second"
        
        lives.media?.append(liveList2)
        
        let liveList3: LiveModel = LiveModel()
        liveList3.media_url = "https://wowzaprod114-i.akamaihd.net/hls/live/678947/92320d61/playlist.m3u8"
        liveList3.subject = "Third"
        
        lives.media?.append(liveList3)
        
        let liveList4: LiveModel = LiveModel()
        liveList4.media_url = "https://c2c-gdny-media-live.conects.com/transcoder_1923977/2145608_6e93916f.0.mp4"
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
        playerScrollViewController.viewModel.index = 0
        
        self.present(playerScrollViewController, animated: true, completion: nil)
    }
 
    override func viewDidLoad() {
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
