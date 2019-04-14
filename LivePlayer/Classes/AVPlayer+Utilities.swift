//
//  AVPlayer+Utilities.swift
//  Pods
//
//  Created by King, Gavin on 3/7/17.
//
//

import Foundation
import AVFoundation

extension AVPlayer {
    
    var errorForPlayerOrItem: NSError? {
        // First try to return the current item's error
        
        if let error = currentItem?.error {
            // If current item's error has an underlying error, return that
            
            if let underlyingError = (error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError {
                return underlyingError
            }
            return error as NSError?
        }
        
        // Otherwise, try to return the player error
        
        if let error = error {
            return error as NSError?
        }
        return nil
    }
}
