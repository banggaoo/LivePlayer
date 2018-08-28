//
//  RegularPlayer_Capability.swift
//  LivePlayer
//
//  Created by st on 17/08/2018.
//

import Foundation
import AVKit

// MARK: Capability Protocols

extension RegularPlayer: AirPlayCapable
{
    public var isAirPlayEnabled: Bool
    {
        get
        {
            return self.player.allowsExternalPlayback
        }
        set
        {
            return self.player.allowsExternalPlayback = newValue
        }
    }
}

#if os(iOS)
extension RegularPlayer: PictureInPictureCapable
{
    @available(iOS 9.0, *)
    public var pictureInPictureController: AVPictureInPictureController?
    {
        return self._pictureInPictureController
    }
}
#endif

extension RegularPlayer: VolumeCapable
{
    public var volume: Float
    {
        get
        {
            return self.player.volume
        }
        set
        {
            self.player.volume = newValue
        }
    }
}

extension RegularPlayer: FillModeCapable
{
    public var fillMode: FillMode
    {
        get
        {
            let gravity = (self.view.layer as! AVPlayerLayer).videoGravity
            
            return gravity == .resizeAspect ? .fit : .fill
        }
        set
        {
            let gravity: AVLayerVideoGravity
            
            switch newValue
            {
            case .fit:
                
                gravity = .resizeAspect
                
            case .fill:
                
                gravity = .resizeAspectFill
            }
            
            (self.view.layer as! AVPlayerLayer).videoGravity = gravity
        }
    }
}

extension RegularPlayer: TextTrackCapable
{
    public var selectedTextTrack: TextTrackMetadata?
    {
        guard let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
        {
            return nil
        }
        
        if #available(iOS 9.0, *)
        {
            return self.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group)
        }
        else
        {
            return self.player.currentItem?.selectedMediaOption(in: group)
        }
    }
    
    public var availableTextTracks: [TextTrackMetadata]
    {
        guard let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
        {
            return []
        }
        return group.options
    }
    
    public func fetchTextTracks(completion: @escaping ([TextTrackMetadata], TextTrackMetadata?) -> Void)
    {
        self.player.currentItem?.asset.loadValuesAsynchronously(forKeys: [#keyPath(AVAsset.availableMediaCharacteristicsWithMediaSelectionOptions)]) { [weak self] in
            guard let strongSelf = self, let group = strongSelf.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
            {
                completion([], nil)
                return
            }
            if #available(iOS 9.0, *)
            {
                completion(group.options, strongSelf.player.currentItem?.currentMediaSelection.selectedMediaOption(in: group))
            }
            else
            {
                completion(group.options, strongSelf.player.currentItem?.selectedMediaOption(in: group))
            }
        }
    }
    
    public func select(_ textTrack: TextTrackMetadata?)
    {
        guard let group = self.player.currentItem?.asset.mediaSelectionGroup(forMediaCharacteristic: .legible) else
        {
            return
        }
        
        guard let track = textTrack else
        {
            self.player.currentItem?.select(nil, in: group)
            return
        }
        
        let option = group.options.first(where: { option in
            track.matches(option)
        })
        self.player.currentItem?.select(option, in: group)
    }
}

extension AVMediaSelectionOption: TextTrackMetadata
{
    public var isSDHTrack: Bool
    {
        return self.hasMediaCharacteristic(.describesMusicAndSoundForAccessibility) && self.hasMediaCharacteristic(.transcribesSpokenDialogForAccessibility)
    }
}
