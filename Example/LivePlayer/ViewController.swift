//
//  ViewController.swift
//  LivePlayer
//
//  Created by banggaoo on 08/01/2018.
//  Copyright (c) 2018 banggaoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func didTapSingleVideoButton(_ sender: Any) {
        guard let live = LiveModel.decodeJsonData(jsonString: DummyData.singleLiveData) else { return }
        presentPlayerVC(with: live)
    }
    
    @IBAction func didTapSingleVideoWithBGButton(_ sender: Any) {
        guard let live = LiveModel.decodeJsonData(jsonString: DummyData.singleLiveData) else { return }
        presentPlayerVC(with: live, isBackgroundPlayEnabled: true)
    }

    @IBAction func didTapSingleAudioButton(_ sender: Any) {
        guard let live = LiveModel.decodeJsonData(jsonString: DummyData.singleLiveData) else { return }
        presentPlayerVC(with: live)
    }

    @IBAction func didTapSingleAudioWithBGButton(_ sender: Any) {
        guard let live = LiveModel.decodeJsonData(jsonString: DummyData.singleLiveData) else { return }
        presentPlayerVC(with: live, isBackgroundPlayEnabled: true)
    }

    private func presentPlayerVC(with live: LiveModel, isBackgroundPlayEnabled: Bool = false) {
        let vc = PlayerViewController(with: live)
        vc.isBackgroundPlayEnabled = isBackgroundPlayEnabled
        present(vc, animated: true, completion: nil)
    } 
}
