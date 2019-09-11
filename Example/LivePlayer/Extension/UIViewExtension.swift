//
//  UIViewExtension.swift
//  LivePlayer_Example
//
//  Created by James Lee on 02/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

extension UIView {
    
    func addSubviewWithFullsize(_ subview: UIView) {
        addSubview(subview, with: UIEdgeInsets.zero)
    }
    func addSubview(_ subview: UIView, with edge: UIEdgeInsets) {
        self.addSubview(subview)
        
        setConstraint(subview, with: edge)
    }
    
    func setConstraint(_ subview: UIView, with edge: UIEdgeInsets) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge.right).isActive = true
        subview.topAnchor.constraint(equalTo: topAnchor, constant: edge.top).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -edge.bottom).isActive = true
    }
    
    func removeFromSuperviewIfIn() {
        guard superview != nil else { return }
        removeFromSuperview()
    }
}
