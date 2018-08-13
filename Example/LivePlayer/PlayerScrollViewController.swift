//
//  PlayerScrollViewController.swift
//  GDNY
//
//  Created by st on 01/08/2018.
//  Copyright © 2018 st. All rights reserved.
//

import UIKit
import LivePlayer

class PlayerScrollViewController: UIViewController, PlayerViewDelegate {
    let viewModel = PlayerScrollViewModel()

    var infinitePageViewController: InfinitePageViewController?

    var viewControllers: [PlayerViewController] = [PlayerViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Depend on device's performance
        let numberOfPlayers = 5

        for _ in 0...(numberOfPlayers - 1) {

            let playerViewController: PlayerViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController

            playerViewController.delegate = self

            viewControllers.append(playerViewController)
        }

        infinitePageViewController = UIStoryboard(name: "Player", bundle: nil).instantiateViewController(withIdentifier: "InfinitePageViewController") as? InfinitePageViewController

        guard let infinitePageViewController = infinitePageViewController else { return }

        infinitePageViewController.controllers = viewControllers

        infinitePageViewController.scrollDelegate = self

        addChildViewController(infinitePageViewController)
        view.addSubview(infinitePageViewController.view)
        infinitePageViewController.didMove(toParentViewController: self)

        guard let currentViewController: PlayerViewController = infinitePageViewController.viewControllers?.first as? PlayerViewController else { return }

        placePlayers(index: viewModel.index, viewController: currentViewController)
    }

    func placePlayers(index: Int, viewController: UIViewController) {

        guard let currentLive = viewModel.list?[index], let videoString = currentLive.media_url, let videoURL = URL(string: videoString) else { return }

        guard let viewController: PlayerViewController = viewController as? PlayerViewController else { return }

        viewController.videoURL = videoURL
    }

    @objc func didTapExitButton() {

        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapPlayButton(_ player: RegularPlayer) {

    }
}

extension PlayerScrollViewController: InfinitePageViewDelegate {

    func getNextIndex(offset: Int) -> Int {

        var nextIndex = viewModel.index + offset

        // If reach end of list, Reverse
        nextIndex = viewModel.list!.reverseOverflow(nextIndex)

        return nextIndex
    }

    func getNextIndex(isDown: Bool) -> Int {

        let offset = isDown ? 1 : -1

        return getNextIndex(offset: offset)
    }

    func getViewController(baseIndex: Int, offset: Int) -> UIViewController {

        var newIndex = baseIndex + offset

        newIndex = viewControllers.reverseOverflow(newIndex)

        return viewControllers[newIndex]
    }

    func loadPlayer(offset: Int, base: UIViewController) {

        let newIndex = getNextIndex(offset: offset)

        guard let baseIndex = viewControllers.index(of: base as! PlayerViewController) else { return }

        let newViewController = getViewController(baseIndex: baseIndex, offset: offset)

        placePlayers(index: newIndex, viewController: newViewController)
    }

    func willChange(isDown: Bool, newViewController: UIViewController) {

        let nextIndex = getNextIndex(isDown: isDown)

        print("willChange \(nextIndex)")

        placePlayers(index: nextIndex, viewController: newViewController)
    }

    func didChange(isDown: Bool, newViewController: UIViewController) {

        let newIndex = getNextIndex(isDown: isDown)

        viewModel.index = newIndex

        print("didChange \(newIndex)")

        // Preload player
        loadPlayer(offset: -1, base: newViewController)
        loadPlayer(offset: 1, base: newViewController)

        if isDown {

            loadPlayer(offset: -2, base: newViewController)

        } else {

            loadPlayer(offset: 2, base: newViewController)
        }
    }
}

extension Array {

    func reverseOverflow(_ index: Int) -> Int {

        if self.count <= index {
            return 0
        }

        if 0 > index {
            return self.count - 1
        }

        return index
    }
}
