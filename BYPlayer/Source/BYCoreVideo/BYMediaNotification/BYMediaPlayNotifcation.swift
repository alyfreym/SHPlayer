//
//  BYMediaPlayNotifcation.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
import AVFoundation

class BYMediaPlayNotifcation: NSObject {
    private var playbackFinishedNotification: NSObjectProtocol?
    private var playbackStalledNotification: NSObjectProtocol?
    private var playbackFailedToPlayToEndTimeNotification: NSObjectProtocol?
    private var playbackAccessLogEntryNotification: NSObjectProtocol?
    private var playbackErrorLogEntryNotification: NSObjectProtocol?
    private var willResignActiveNotification: NSObjectProtocol?
    private var handleTimebaseRateChangedNotification: NSObjectProtocol?
    weak var notificationProtocol:BYMediaPlaybackNotificationProtocol?
    var player:AVPlayer!
    
    override init() {
        super.init()
        
    }
    
    func registerPlaybackNotofication() {
        self.registerPlayToEndTimeNotification()
        self.registerPlaybackStalledNotification()
        self.registerFailedToPlayToEndTimeNotification()
        self.registerPlaybackLogNotification()
        self.appWillResignActiveNotification()
        
        // 注册 kCMTimebaseNotification_EffectiveRateChanged 通知, 会导致在模拟器上导致模拟器出现卡死不懂的情况
        #if targetEnvironment(simulator)
        #else
        //self.handleTimebaseRateChanged()
        #endif
        
        BYMediaRemoteControlNotifcation.notification().registerMediaSessionNotification()
    }
    
    //播放失败的通知
    private func registerFailedToPlayToEndTimeNotification() {
        playbackStalledNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: player.currentItem, queue: OperationQueue.main, using: { (notification:Notification) in
            guard let playItem:AVPlayerItem = (notification.object as? AVPlayerItem) else {
                return
            }
            if playItem == BYMediaStreams.shareInstance().player.currentItem {
                self.notificationProtocol?.mediaFailedToPlayToEndTimeNotification()
                BYMediaMeasuringLog.accessLog(playerItem: playItem)
                BYMediaMeasuringLog.errorLog(playerItem: playItem)
            }
        })
    }
    //播放中断的通知, 如果缓冲数据不够, 则会走该通知, 待到缓冲数据充足时, 会继续播放, 如果播放的是本地的音视频文件, 走了该通知, 说明该文件有问题, 不会继续播放
    private func registerPlaybackStalledNotification() {
        playbackStalledNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemPlaybackStalled, object: player.currentItem, queue: OperationQueue.main, using: { (notification:Notification) in
            guard let playItem:AVPlayerItem = (notification.object as? AVPlayerItem) else {
                return
            }
            if playItem == BYMediaStreams.shareInstance().player.currentItem {
                print("AVPlayerItemPlaybackStalled")                
                BYMediaMeasuringLog.accessLog(playerItem: playItem)
                BYMediaMeasuringLog.errorLog(playerItem: playItem)
//                self.notificationProtocol?.mediaPlayStalledNotification()
            }
        })
    }
    //播放完成的通知
    private func registerPlayToEndTimeNotification() {
        playbackFinishedNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: OperationQueue.main) { (notification:Notification) in
            //if let finishNotification = self.playFinishedNotification {
            //    NotificationCenter.default.removeObserver(finishNotification)
            //    self.playFinishedNotification = nil
            //}
            guard let playItem:AVPlayerItem = (notification.object as? AVPlayerItem) else {
                return
            }
            if playItem == BYMediaStreams.shareInstance().player.currentItem {
                self.notificationProtocol?.mediaPlayToEndTimeNotification()
            }
        }
    }
    
    //播放日志
    private func registerPlaybackLogNotification() {
        playbackAccessLogEntryNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemNewAccessLogEntry, object: player.currentItem, queue: OperationQueue.main, using: { (notification:Notification) in
            guard let playItem:AVPlayerItem = (notification.object as? AVPlayerItem) else {
                return
            }
            if playItem == BYMediaStreams.shareInstance().player.currentItem {
                BYMediaMeasuringLog.accessLog(playerItem: playItem)
                BYMediaMeasuringLog.errorLog(playerItem: playItem)
            }
        })
        
        playbackErrorLogEntryNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: player.currentItem, queue: OperationQueue.main, using: { (notification:Notification) in
            guard let playItem:AVPlayerItem = (notification.object as? AVPlayerItem) else {
                return
            }
            if playItem == BYMediaStreams.shareInstance().player.currentItem {
                BYMediaMeasuringLog.accessLog(playerItem: playItem)
                BYMediaMeasuringLog.errorLog(playerItem: playItem)
            }
        })
    }
    
    private func appWillResignActiveNotification() {
        // object 必须是nil, f如果是self 则不会走通知
        willResignActiveNotification = NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { (notification:Notification) in
            BYMediaPlayManager.shareInstance().pause()
        }
    }
    
    private func handleTimebaseRateChanged() {
        handleTimebaseRateChangedNotification = NotificationCenter.default.addObserver(forName: .TimebaseEffectiveRateChangedNotification, object: player.currentItem?.timebase, queue: OperationQueue.main) { (note:Notification) in
//            if CMTimebaseGetTypeID() == CFGetTypeID(note.object as CFTypeRef) {
//                let timebase = note.object as! CMTimebase
//                let rate: Double = CMTimebaseGetRate(timebase)
//                print("AVPlayerItem.timebase = \(rate)")
//            }
        }
    }
}
extension Notification.Name {
    /// Notification for when a timebase changed rate
    static let TimebaseEffectiveRateChangedNotification = Notification.Name(rawValue: kCMTimebaseNotification_EffectiveRateChanged as String)
}
