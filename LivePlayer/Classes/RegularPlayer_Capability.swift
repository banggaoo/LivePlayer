//
//  RegularPlayer_Capability.swift
//  LivePlayer
//
//  Created by st on 17/08/2018.
//

import Foundation
import AVKit

// MARK: Capability Protocols

extension RegularPlayer: AirPlayCapable {
    public var isAirPlayEnabled: Bool {
        get { return player.allowsExternalPlayback }
        set { return player.allowsExternalPlayback = newValue }
    }
}

#if os(iOS)
extension RegularPlayer: PictureInPictureCapable {
    public var pictureInPictureController: AVPictureInPictureController? {
        return _pictureInPictureController
    }
}
#endif

extension RegularPlayer: VolumeCapable {
    public var volume: Float {
        get { return player.volume }
        set { player.volume = newValue }
    }
}

extension RegularPlayer: FillModeCapable {
    public var fillMode: FillMode {
        get {
            let gravity = (view.layer as? AVPlayerLayer)?.videoGravity
            return getFillMode(by: gravity)
        }
        set (newValue) {
            let gravity = getVideoGravity(by: newValue)
            (view.layer as? AVPlayerLayer)?.videoGravity = gravity
        }
    }
    
    private func getFillMode(by gravity: AVLayerVideoGravity?) -> FillMode {
        return gravity == .resizeAspect ? .fit : .fill
    }
    private func getVideoGravity(by fillMode: FillMode) -> AVLayerVideoGravity {
        switch fillMode {
        case .fit: return .resizeAspect
        case .fill: return .resizeAspectFill
        }
    }
}

extension RegularPlayer: TextTrackCapable {
    
    public var selectedTextTrack: TextTrackMetadata? {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return nil }
        return player.currentItem?.currentMediaSelection.selectedMediaOption(in: group)
    }
    
    public var availableTextTracks: [TextTrackMetadata] {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return [] }
        return group.options
    }
    
    public func fetchTextTracks(completion: @escaping ([TextTrackMetadata], TextTrackMetadata?) -> Void) {
        player.currentItem?.asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.availableMediaCharacteristicsWithMediaSelectionOptions)]) { [weak self] in
            guard
                let `self` = self,
                let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else {
                completion([], nil)
                return
            }
            completion(group.options, self.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group))
        }
    }
    
    public func select(_ textTrack: TextTrackMetadata?) {
        guard let group = player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else { return }
        guard let track = textTrack else {
            player.currentItem?.select(nil, in: group)
            return
        }
        
        let option = group.options.first(where: { option in
            track.matches(option)
        })
        player.currentItem?.select(option, in: group)
    }
}

extension AVMediaSelectionOption: TextTrackMetadata {
    public var isSDHTrack: Bool {
        return hasMediaCharacteristic(.describesMusicAndSoundForAccessibility) && hasMediaCharacteristic(.transcribesSpokenDialogForAccessibility)
    }
}

