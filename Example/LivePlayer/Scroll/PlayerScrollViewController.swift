//
//  PlayerScrollViewController.swift
//  GDNY
//
//  Created by James Lee on 21/08/2019.
//  Copyright © 2019 st. All rights reserved.
//

import UIKit
import AVFoundation

final class PlayerScrollViewController: UIViewController {
    
    private let lives: [LiveModel]
    private var liveCount: Int { return lives.count }
    
    init(lives: [LiveModel]) {
        self.lives = lives
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        guard let vc = self.infinitePageViewController.currentViewController else { return }
        self.configurePage(at: 0, vc: vc)
        self.playPage(vc)
        self.configurePage(from: vc, offset: 1)
        self.configurePage(from: vc, offset: -1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Setup
    
    private func setup() {
        extendedLayoutIncludesOpaqueBars = false
        edgesForExtendedLayout = []
        AVAudioSession.sharedInstance().setAmbientCategory()
        addInfinitePageViewController()
    }
    
    private func addInfinitePageViewController() {
        addChild(infinitePageViewController)
        view.addSubview(infinitePageViewController.view)
        infinitePageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infinitePageViewController.view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            infinitePageViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            infinitePageViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            infinitePageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        infinitePageViewController.didMove(toParent: self)
    }
    
    // MARK: UI
    
    private lazy var infinitePageViewController: InfinitePageViewController = {
        let vcs = (0...4).map { i -> PlayerScrollPageViewController in
            let vc = PlayerScrollPageViewController()
            vc.view.backgroundColor = .black  // For enable touch event
            vc.delegate = self
            return vc
        }
        let vc = InfinitePageViewController(pageViewControllers: vcs)
        vc.scrollDelegate = self
        return vc
    }()
    
    private func configurePage(at index: Int, vc: UIViewController) {
        guard let vc = vc as? PlayerScrollPageViewController else { return }
        guard let live = lives[safe: index] else { return }
        vc.configure(live: live)
    }
    
    private func rewindPageIfNeeded(_ vc: UIViewController) {
        guard let vc = vc as? PlayerScrollPageViewController else { return }
        vc.rewindIfNeeded()
    }
    
    private func playPage(_ vc: UIViewController) {
        guard let vc = vc as? PlayerScrollPageViewController else { return }
        vc.play()
    }
    
    private func configurePage(from vc: UIViewController, offset: Int) {
        guard let index = getIndex(of: vc) else { return }
        guard let new = infinitePageViewController.getCirculatedViewController(from: vc, offset: offset) else { return }
        guard let newIndex = getCirculatedIndex(from: index, offset: offset) else { return }
        configurePage(at: newIndex, vc: new)
    }
    
    private func getIndex(of viewController: UIViewController) -> Int? {
        guard
            let liveHashValue = (viewController as? PlayerScrollPageViewController)?.liveHashValue,
            let index = getIndex(of: liveHashValue) else { return nil }
        return index
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc
    private func willEnterForeground() {
        guard let vc = infinitePageViewController.currentViewController else { return }
        playPage(vc)
    }
    
    // MARK: Data
    
    func getIndex(of liveHashValue: Int) -> Int? {
        for (index, live) in lives.enumerated() {
            if liveHashValue == live.hashValue { return index }
        }
        return nil
    }
    
    func getCirculatedIndex(from index: Int, offset: Int) -> Int? {
        guard liveCount > 0 else { return nil }
        let maxIndex = liveCount - 1
        let remainderOffset = abs(offset) > maxIndex ? offset % liveCount : offset
        let offsetIndex = index + remainderOffset
        if offsetIndex > maxIndex { return offsetIndex - liveCount }
        if offsetIndex < 0 { return liveCount + offsetIndex }
        return offsetIndex
    }
}

extension PlayerScrollViewController: InfinitePageViewDelegate {
    
    func canChange(offset: Int, current: UIViewController) -> Bool {
        return true // Infinite Scroll
    }
    
    func willChange(offset: Int, current: UIViewController, new: UIViewController) {
        configurePage(from: current, offset: offset)
        rewindPageIfNeeded(new)
    }
    
    func didChange(offset: Int, current: UIViewController) {
        //        playPage(current)
        //        configurePage(from: current, offset: offset)
        //        let increment = offset > 0 ? 1 : -1
        //        configurePage(from: current, offset: offset + increment)
    }
}

extension PlayerScrollViewController: PlayerScrollPageViewControllerDelegate {

    func didTapProfileButton(_ sender: PlayerScrollPageViewController, id: Int) {
//        let vc = ProfileViewController(userId: "\(id)", chatId: nil)
//        vc.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(vc, animated: true)
    }

    func didEndPlaying(_ sender: PlayerScrollPageViewController) {
        infinitePageViewController.moveIfCan(from: sender, offset: 1)
    }
}
