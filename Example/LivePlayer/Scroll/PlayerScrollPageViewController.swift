//
//  PlayerScrollPageViewController.swift
//  GDNY
//
//  Created by James Lee on 22/08/2019.
//  Copyright © 2019 st. All rights reserved.
//

import UIKit

protocol PlayerScrollPageViewControllerDelegate: class {
    func didTapProfileButton(_ sender: PlayerScrollPageViewController, id: Int)
    func didEndPlaying(_ sender: PlayerScrollPageViewController)
}

final class PlayerScrollPageViewController: UIViewController {
    var playerState: PlayerController.PlayerState = .undefined
    
    private(set) var liveHashValue: Int?
    
    weak var delegate: PlayerScrollPageViewControllerDelegate?
    
    // MARK: Interface
    
    func configure(live: LiveModel) {
        self.liveHashValue = live.hashValue
        configure(
            videoUrlStr: live.media_url)
    }
    private func configure(videoUrlStr: String?) {
        if let urlStr = videoUrlStr {
            let url = URL(string: urlStr)
            playerController.loadVideo(
                with: url,
                type: .vod,
                published: true)
        }
    }
    
    func play() {
        playerController.play()
    }
    func rewindIfNeeded() {
        playerController.rewindIfNeeded()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playerController.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerController.pause()
    }
    
    // MARK: Setup
    
    private func setup() {
        playerController.insertPlayerView(in: view)
    }
    
    // MARK: UI
    private lazy var playerController: PlayerController = {
        let ctr = PlayerController()
        ctr.player.fillMode = .fill
        ctr.delegate = self
        return ctr
    }()
}

extension PlayerScrollPageViewController: PlayerControllerDelegate {
    
    func didChangePlayerState(_ state: PlayerController.PlayerState) {
        print("didChangePlayerState \(state)")
        guard playerState != state else { return }
        guard playerState == .empty, state == .failed else { return }
        playerState = state
        
//        switch state {
//        case .undefined,
//             .loading:
//            backgroundPresenter.presentType = .loading(message: "로딩중..")
//        case .ready:
//            backgroundPresenter.presentType = .control
//        case .empty:
//            backgroundPresenter.showMessage(with: .empty)
//        case .failed:
//            backgroundPresenter.showMessage(with: .bad(type: .vod))
//        }
    }
    
    func didFailedLoadBecause(_ state: PlayerController.FailedState) {
        print("didFailedLoadBecause \(state)")
//        switch state {
//        case .ended:
//            backgroundPresenter.showMessage(with: .end)
//        case .empty:
//            backgroundPresenter.showMessage(with: .empty)
//        }
    }
    
    func didUpdateTimeControlStatus(_ playing: Bool) {
        print("didUpdateTimeControlStatus \(playing)")
    }
    
    func playerDidUpdateTime(_ time: TimeInterval, _ duration: TimeInterval) {
        print("playerDidUpdateTime \(time) \(duration)")
        if time > 0, time == duration {
            delegate?.didEndPlaying(self)
        }
    }
}

