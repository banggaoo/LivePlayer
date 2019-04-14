//
//  CustomSlider.swift
//  LivePlayer_Example
//
//  Created by James Lee on 14/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

open class CustomSlider: UISlider {
    
    @IBInspectable open var trackWidth: CGFloat = 2 {
        didSet {setNeedsDisplay()}
    }
    
    override open func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height/2 - trackWidth/2,
            width: defaultBounds.size.width,
            height: trackWidth
        )
    }
    
    override open func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        
        let multiValue: Float = value - 0.5
        let pixelAdjustment: Float = 35.0
        let xOriginDelta: Float = multiValue * ( Float(bounds.size.width) - pixelAdjustment)
        
        return CGRect(
            x: bounds.origin.x + CGFloat(xOriginDelta),
            y: bounds.origin.y,
            width: bounds.size.width,
            height: bounds.size.height
        )
    }
}

