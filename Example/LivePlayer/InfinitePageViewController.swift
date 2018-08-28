//
//  InfinitePageViewController.swift
//  GDNY
//
//  Created by st on 02/08/2018.
//  Copyright © 2018 st. All rights reserved.
//

import UIKit

public protocol InfinitePageViewDelegate: class {
    func canChange(isDown: Bool) -> Bool
    func willChange(isDown: Bool, newViewController: UIViewController)
    func didChange(isDown: Bool, newViewController: UIViewController)
}

public class InfinitePageViewController: UIPageViewController {
    public var controllers: [UIViewController]?
    public weak var scrollDelegate: InfinitePageViewDelegate?

    override public func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        dataSource = self

        guard let firstViewController = controllers?.first else { return }

        setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
    }
    
    func setScrollEnable(_ isEnabled: Bool) {
        
        for view in view.subviews {
            if let subView = view as? UIScrollView {
                subView.isScrollEnabled = isEnabled
            }
        }
    }
}

extension InfinitePageViewController: UIPageViewControllerDelegate {

    private func getDirection(currentViewController: UIViewController, newViewController: UIViewController) -> Bool {
        guard let currentIndex = controllers?.index(of: currentViewController) else { return false }
        guard let newIndex = controllers?.index(of: newViewController) else { return false }

        var isDown: Bool = currentIndex < newIndex ? true : false

        if abs(currentIndex - newIndex) == ((controllers?.count)! - 1) {
            // If pages are reversed, reverse direction
            isDown = !isDown
        }
        
        return isDown
    }

    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let newViewController: UIViewController = pendingViewControllers.first, let currentViewController: UIViewController = pageViewController.viewControllers?.first else { return }

        let isDown = getDirection(currentViewController: currentViewController, newViewController: newViewController)

        scrollDelegate?.willChange(isDown: isDown, newViewController: newViewController)
    }

    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }

        guard let currentViewController: UIViewController = previousViewControllers.first, let newViewController: UIViewController = pageViewController.viewControllers?.first else { return }

        let isDown = getDirection(currentViewController: currentViewController, newViewController: newViewController)

        scrollDelegate?.didChange(isDown: isDown, newViewController: newViewController)
    }
}

extension InfinitePageViewController: UIPageViewControllerDataSource {

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = controllers?.index(of: viewController) else { return nil }

        if let isCanChange: Bool = scrollDelegate?.canChange(isDown: false), isCanChange == false {
            return nil
        }

        if index == 0 {
            return controllers?.last
        }

        let previousIndex = index - 1
        return controllers?[previousIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = controllers?.index(of: viewController) else { return nil }

        let nextIndex = index + 1
        if nextIndex == controllers?.count {

            return controllers?.first
        }

        return controllers?[nextIndex]
    }
}
