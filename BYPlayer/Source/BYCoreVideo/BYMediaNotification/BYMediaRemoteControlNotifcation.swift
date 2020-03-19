//
//  BYMediaRemoteControlNotifcation.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/12.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
import AVFoundation

class BYMediaRemoteControlNotifcation: NSObject {
    
    var headphonesConnected = false
    var isHasNotification = false
    static private let staticInstance: BYMediaRemoteControlNotifcation = BYMediaRemoteControlNotifcation()
    static func notification() -> BYMediaRemoteControlNotifcation {
        return staticInstance
    }
    
    private override init() {
        
    }
    
    
    func registerMediaSessionNotification() {
        self.registerMediaSessionInterrupt()
        self.registerMediaSessionRouteChange()
        self.registerMediaSessionMediaServicesWereReset()
        self.setupNotifications()
        isHasNotification = true
    }
    
    func removeMediaSessionNotification() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.mediaServicesWereResetNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
        isHasNotification = false
    }
    /// 打断
    func registerMediaSessionInterrupt() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleInterruption),
                                       name: AVAudioSession.interruptionNotification,
                                       object: nil)
        
    }
    
    /// 媒体服务器重启
    func registerMediaSessionMediaServicesWereReset() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleMediaServiceReset),
                                       name: AVAudioSession.mediaServicesWereResetNotification,
                                       object: nil)
    }
    
    /// 响应路径变化
    func registerMediaSessionRouteChange() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(handleRouteChange),
                                       name: AVAudioSession.routeChangeNotification,
                                       object: nil)
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleSecondaryAudio),
                                               name: AVAudioSession.silenceSecondaryAudioHintNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    @objc func handleSecondaryAudio(notification: Notification) {
        // Determine hint type
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
            let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue) else {
                return
        }
        
        if type == .begin {
            //            XLToast.showToast(message: "其他的App开始播放", duration: 3)
            // Other app audio started playing - mute secondary audio
        } else {
            //            XLToast.showToast(message: "其他的App停止播放", duration: 3)
            // Other app audio stopped playing - restart secondary audio
        }
    }
    
    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
                return
        }
        switch reason {
        case .newDeviceAvailable:
            let session = AVAudioSession.sharedInstance()
            for output in session.currentRoute.outputs where convertFromAVAudioSessionPort(output.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) {
                headphonesConnected = true
                //                if BYPlaybackSession.shareInstance().playState == .playing {
                //                    BYPlaybackSession.shareInstance().play {
                //                    }
                //                }
                break
            }
        case .oldDeviceUnavailable:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where convertFromAVAudioSessionPort(output.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) {
                    headphonesConnected = false
                    BYMediaPlaySession.playSession().pauseVideo()
                    break
                }
            }
        case .override:
            if let previousRoute =
                userInfo[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription {
                for output in previousRoute.outputs where convertFromAVAudioSessionPort(output.portType) == convertFromAVAudioSessionPort(AVAudioSession.Port.headphones) {
                    headphonesConnected = false
                    BYMediaPlaySession.playSession().pauseVideo()
                    break
                }
            }
        default: ()
        }
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                return
        }
        if type == .began {
//            if BYPlaybackSession.shareInstance().playState == .playing {
//                BYPlaybackSession.shareInstance().pause {
//                    
//                }
//            }
            // Interruption began, take appropriate actions
        }else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
//                    if BYPlaybackSession.shareInstance().playState == .paused {
//                        BYPlaybackSession.shareInstance().play {
//
//                        }
//                    }
                    // Interruption Ended - playback should resume
                } else {

                }
            }
        }
    }
    
    @objc func handleMediaServiceReset(notification: Notification) {
        print(notification.userInfo as Any)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionPort(_ input: AVAudioSession.Port) -> String {
    return input.rawValue
}
