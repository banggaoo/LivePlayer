//
//  BasePlayerViewController.swift
//  LivePlayer_Example
//
//  Created by James Lee on 14/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

class BasePlayerViewController: UIViewController {
    
    var isStatusBarHidden = false {
        didSet { setNeedsStatusBarAppearanceUpdate() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient,
                                                         mode: .moviePlayback,
                                                         options: [.mixWithOthers])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (UIApplication.shared.delegate as? AppDelegate)?.rotateLock = false

        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        (UIApplication.shared.delegate as? AppDelegate)?.rotateLock = true
        
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    // MARK: UIWindow
    
    override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    open override var shouldAutorotate: Bool {
        get {
            return true
        }
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    open override var childForHomeIndicatorAutoHidden: UIViewController? {
        return self.presentedViewController
    }
    
}
