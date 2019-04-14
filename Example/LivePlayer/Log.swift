//
//  Log.swift
//  LivePlayer_Example
//
//  Created by James Lee on 14/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

func printLog(fileFullPath: String = #file, fc: String = #function, line: Int = #line, _ arg: Any?) {
    #if DEBUG
    let filename = fileFullPath.components(separatedBy: "/").last ?? "UnknownFile"
    print("[\(filename).\(fc):\(line) \(NSDate())]\n\(String(describing: arg))")
    #endif
}
