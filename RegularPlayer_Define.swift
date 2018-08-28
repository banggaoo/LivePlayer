//
//  RegularPlayer_Define.swift
//  LivePlayer
//
//  Created by st on 28/08/2018.
//

import Foundation

public struct KeyPath
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
