//
//  BYMediaStreamsProtocol.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

enum BYMediaStreamsLoadStatus : Int {
    case unknown
    case loading
    case loaded
    case failed
    case cancelled
}

/**
 * 音频资源播放状态
 */
enum BYMediaStreamsPlayStatus : Int {
    case unknown
    case playing
    case paused
    case failed
    case stoped
    case buffering
}

/**
 * BYMediaStreams 协议
 */
protocol BYMediaStreamsProtocol: NSObjectProtocol {
    func mediaLoadStreamsStatus(valueStatus:BYMediaStreamsLoadStatus)
    func mediaPlayStreamsStatus(valueStatus:BYMediaStreamsPlayStatus)
    func mediaPlayTimeChange(currentTime:TimeInterval, duration:TimeInterval)
    func mediaStremasBufferTimeChnage(bufferTime:TimeInterval, duration:TimeInterval)
    func mediaPlayToFinished()
    func mediaStremasBufferEmpty()
    func mediaStremasBufferFull()
}

/**
 * BYMediaPlayManager 协议
 */
protocol BYMediaPlaybackProtocol : NSObjectProtocol {
    func mediaPlaybackAssetUrls() -> (assetUrls:[URL], playIndex:Int)
    func mediaBufferTimeChanged(bufferTime: TimeInterval, duration: TimeInterval)
    func mediaPlayTimeChanged(currentTime: TimeInterval, duration: TimeInterval)
    func mediaPlaybackState(status: BYMediaStreamsPlayStatus)
    func mediaPlaybackLoadState(status: BYMediaStreamsLoadStatus)
    func mediaPlayCurrentPlay(index: Int)
    func mediaPlayToEndTime(index:Int)
    func mediaPlay(callback:(_ isPlay: Bool) -> Swift.Void)
    func mediaFullScreen(callback:(Bool) -> Swift.Void) -> CGRect
    func mediaPlayLayer(playLayer:UIView)
}

/**
 * 播放通知 协议
 */
protocol BYMediaPlaybackNotificationProtocol: NSObjectProtocol {
    func mediaFailedToPlayToEndTimeNotification()
    func mediaPlayStalledNotification()
    func mediaPlayToEndTimeNotification()
}
