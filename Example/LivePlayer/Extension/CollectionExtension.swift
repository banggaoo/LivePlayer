//
//  CollectionExtension.swift
//  LivePlayer_Example
//
//  Created by James Lee on 02/09/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
