//
//  RegularPlayer_Define.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation

public struct RegularPlayerConstants
{
    public static let TimeUpdateInterval: TimeInterval = 1.0
    public static let TimerInterval: TimeInterval = 2.0
    public static let AssetLoadTimeout: TimeInterval = 6.0
    public static let AssetPlayTimeout: TimeInterval = 5.0
}

public struct RegularPlayerKeyPath
{
    struct Player
    {
        static let Rate = "rate"
        static let Status = "status"
        static let TimeControlStatus = "timeControlStatus"
    }
    
    struct PlayerItem
    {
        static let Status = "status"
        static let PlaybackLikelyToKeepUp = "playbackLikelyToKeepUp"
        static let LoadedTimeRanges = "loadedTimeRanges"
        static let PlaybackBufferEmpty = "playbackBufferEmpty"
    }
}
