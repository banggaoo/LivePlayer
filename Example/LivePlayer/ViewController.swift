//
//  ViewController.swift
//  LivePlayer
//
//  Created by banggaoo on 08/01/2018.
//  Copyright (c) 2018 banggaoo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func singleButton(_ sender: Any) {
        guard let live = LiveModel.decodeJsonData(jsonString: DummyData.singleLiveData) else { return }
        presentPlayerVC(with: live)
    }
    
    private func presentPlayerVC(with live: LiveModel) {
        let vc = PlayerViewController(with: live)
        present(vc, animated: true, completion: nil)
    } 
}
