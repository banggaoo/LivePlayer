//
//  InfinitePageViewController.swift
//  GDNY
//
//  Created by James Lee on 02/08/2018.
//  Copyright © 2018 st. All rights reserved.
//

import UIKit

protocol InfinitePageViewDelegate: class {
    func canChange(offset: Int, current: UIViewController) -> Bool
    func willChange(offset: Int, current: UIViewController, new: UIViewController)
    func didChange(offset: Int, current: UIViewController)
}

final class InfinitePageViewController: UIPageViewController {
    private let pageViewControllers: [UIViewController]
    private var pageCount: Int { return pageViewControllers.count }
    
    weak var scrollDelegate: InfinitePageViewDelegate?
    
    // MARK: Interface
    
    var currentViewController: UIViewController? {
        return viewControllers?.first
    }
    
    func getCirculatedViewController(from vc: UIViewController, offset: Int) -> UIViewController? {
        guard let index = pageViewControllers.firstIndex(of: vc) else { return nil }
        let maxIndex = pageCount - 1
        let remainderOffset = abs(offset) > maxIndex ? offset % pageCount : offset
        let offsetIndex = index + remainderOffset
        var vcIndex = offsetIndex
        if offsetIndex > maxIndex { vcIndex = offsetIndex - pageCount }
        if offsetIndex < 0 { vcIndex = pageCount + offsetIndex }
        return pageViewControllers[safe: vcIndex]
    }
    
    func moveIfCan(from vc: UIViewController, offset: Int) {
        guard let nextVC = getCirculatedViewController(from: vc, offset: offset) else { return }
        view.isUserInteractionEnabled = false
        delegate?.pageViewController?(self, willTransitionTo: [nextVC])
        let direction: NavigationDirection = offset > 0 ? .forward : .reverse
        setViewControllers([nextVC], direction: direction, animated: true) { completed in
            self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [vc], transitionCompleted: true)
            self.view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: Lifecycle
    init(pageViewControllers: [UIViewController]) {
        self.pageViewControllers = pageViewControllers
        super.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: Setup
    private func setup() {
        delegate = self
        dataSource = self
        
        if let vc = pageViewControllers.first {
            setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // MARK: Infinite scroll
    private func getOffset(current: UIViewController, new: UIViewController) -> Int {
        guard
            let currentIndex = pageViewControllers.firstIndex(of: current),
            let newIndex = pageViewControllers.firstIndex(of: new) else { return 0 }
        if abs(currentIndex - newIndex) > 1 {  // reversed
            return currentIndex > newIndex ? 1 : -1
        }
        return newIndex - currentIndex
    }
}

extension InfinitePageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard
            let newVC = pendingViewControllers.first,
            let curVC = pageViewController.viewControllers?.first else { return }
        let offset = getOffset(current: curVC, new: newVC)
        scrollDelegate?.willChange(offset: offset, current: curVC, new: newVC)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        guard
            let curVC = previousViewControllers.first,
            let newVC = pageViewController.viewControllers?.first else { return }
        guard curVC != newVC else { return }
        let offset = getOffset(current: curVC, new: newVC)
        scrollDelegate?.didChange(offset: offset, current: newVC)
    }
}

extension InfinitePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard scrollDelegate?.canChange(offset: -1, current: viewController) ?? false else { return nil }
        let beforeVC = getCirculatedViewController(from: viewController, offset: -1)
        return beforeVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard scrollDelegate?.canChange(offset: 1, current: viewController) ?? false else { return nil }
        let afterVC = getCirculatedViewController(from: viewController, offset: 1)
        return afterVC
    }
}
