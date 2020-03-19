//
//  BYMediaPlaySessionProtocol.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

enum BYMediaPlayerMode {
    case loop           // 循环
    case singleLoop     // 单曲循环
    case random         // 随机
    case single         // 只播一次
}

enum BYMediaPlayerPlaybackState {
    case unknown
    case playing
    case paused
    case failed
    case stoped
    case buffering
}

enum BYMediaPlayerLoadState {
    case unknown
    case loading
    case loaded
    case failed
    case cancelled
}

protocol BYMediaPlaySessionProtocol : NSObjectProtocol {
    func mediaPlayBufferTimeChanged(bufferTime: TimeInterval, duration: TimeInterval)
    func mediaPlayTimeChanged(currentTime: TimeInterval, duration: TimeInterval)
    func mediaPlaybackState(playState: BYMediaPlayerPlaybackState)
    func mediaPlaybackLoadState(status: BYMediaPlayerLoadState)
    func mediaPlayCurrentPlay(index: Int)
    /// 播放结束, index 为当前播放结束的index
    func mediaPlayToEndTime(index:Int)
    func mediaPlay(callback:(_ isPlay: Bool) -> Swift.Void)
    /// 进入全屏的点击事件, 返回值是当前播放视图相对于window的frame
    func mediaFullScreen(callback:(Bool) -> Swift.Void) -> CGRect
    func mediaPlayLayer(playLayer:UIView)
}

extension BYMediaPlaySessionProtocol {
    func mediaPlayBufferTimeChanged(bufferTime: TimeInterval, duration: TimeInterval){}
    func mediaPlayTimeChanged(currentTime: TimeInterval, duration: TimeInterval){}
    func mediaPlaybackState(playState: BYMediaPlayerPlaybackState){}
    func mediaPlaybackLoadState(status: BYMediaPlayerLoadState){}
    func mediaPlayCurrentPlay(index: Int){}
    /// 播放结束, index 为当前播放结束的index
    func mediaPlayToEndTime(index:Int){}
    func mediaPlay(callback:(_ isPlay: Bool) -> Swift.Void) {}
    func mediaPlayLayer(playLayer:UIView) {}
}

