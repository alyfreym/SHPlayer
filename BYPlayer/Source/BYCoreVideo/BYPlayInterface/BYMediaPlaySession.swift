//
//  BYMediaPlaySession.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYMediaPlaySession: NSObject {
    static private let playbackSession = BYMediaPlaySession()
    static func playSession() -> BYMediaPlaySession {
        return playbackSession
    }
    
    var playPattern:BYMediaPlayerMode = BYMediaPlayerMode.single
    private var playState:BYMediaPlayerPlaybackState = .unknown
    private var currentPlayIndex = 0
    private var duration:TimeInterval = 0
    private var currentTime:TimeInterval = 0
    private var isAllowFollowPlay:Bool = false
    private let playbackManager:BYMediaPlayManager = BYMediaPlayManager.shareInstance()
    private var urls:[URL] = []
    private var playContentView:UIView!

    /// 是否允许蜂窝网络播放视频
    var isCellularPlay:Bool = false
    /// 播放状态回调
    weak var playbackSession:BYMediaPlaySessionProtocol?
    /// 当前播放视频的唯一标示符
    var mediaId:String = ""
    /// 视频封面图
    var coverImage:UIImage?
    /// 是否是续播
    var isContinueToPlaying:Bool = false
    /// 当前是否是播放状态
    var isPlaying:Bool {
        get {return playbackManager.isPlaying}
    }

    private var isPlaybackActivity:Bool {
        get {
            if self.playState == .playing || self.playState == .paused || self.playState == .buffering {
                return true
            }
            return false
        }
    }
    
    private override init() {
        super.init()
        playbackManager.playbackProtocol = self
    }
    
    func assetURLs(assetURLs:[URL], playIndex:Int = 0) {
        urls = assetURLs
        currentPlayIndex = playIndex
        if isCellularPlay {
            if MayaNetWork.network().isReachableOnWiFi {
                playMedia(index: playIndex) {}
            }else {
                if self.isAllowFollowPlay {
                    playMedia(index: playIndex) {}
                }else {
                    
                }
            }
        }
    }
    
    // 开启播放
    func playVideo(contentView:UIView) {
        if mediaId.replacingOccurrences(of: " ", with: "").count == 0 {
            print("请设置视频标识")
            return
        }
        BYMediaPlayManager.shareInstance().coverImage = coverImage
        showPlayLayer(contentView: contentView)
        playMedia(index: currentPlayIndex) {}
    }
    
    /// 显示播放器
    func showPlayLayer(contentView:UIView) {
//        if isContinueToPlaying == false {
        BYMediaPlayManager.shareInstance().coverImage = coverImage
//        }
        playbackManager.playContentView = contentView
    }
    
    /// 移除播放器
    func removePlayLayer() {
        playbackManager.playContentView = nil
    }
    
    @discardableResult
    func isSameMedia(mediaId:String) -> Bool {
        let isSame = mediaId == self.mediaId
        if isSame == false {

        }else {
            
        }
        return isSame
    }
}
extension BYMediaPlaySession {
    
    func playMedia(index:NSInteger, callback:()->Void) {
        currentPlayIndex = index
        playbackManager.playbackMedia(callback: {
            
        }, failCallback: {
            
        })
        callback()
    }
    
    /// 如果当前有正在播放的资源, 则进行播放暂停切换, 否则播放第一个资源
    func play(callback:()->Void) {
        if self.isPlaybackActivity {
            if self.playbackManager.isPlaying {
                playbackManager.pause()
            }else {
                playbackManager.play()
            }
        }else {
            playMedia(index: 0) {}
            self.isAllowFollowPlay = true
        }
    }
    
    /// 暂停
    func pauseVideo() {
        playbackManager.pause()
    }
    
    /// 切换播放器状态
    func togglePlayStatus() {
        if self.isPlaybackActivity {
            if self.playbackManager.isPlaying {
                playbackManager.pause()
            }else {
                playbackManager.play()
            }
        }else {
            
        }
    }
    
    // MARK: 停止播放
    func stopVideo() {
//        playState = BYMediaPlayerPlaybackState.stoped
//        playbackManager.playStop()
        mediaId = ""
        urls = []
        currentPlayIndex = 0
        playState = .unknown
        playState = BYMediaPlayerPlaybackState.stoped
        playbackManager.playStop()
    }
    
    // MARK: 重置播放器, 只有点击浮窗的关闭按钮才能调用, 因为音频有的是连续的很多集, 如果直接resetStop, 会把之前的单例里面存放的集数也给清理掉.
    func resetMedia() {
        mediaId = ""
        urls = []
        currentPlayIndex = 0
        playState = .unknown
        playState = BYMediaPlayerPlaybackState.stoped
        playbackManager.playStop()
    }
    
    /// 重新播放
    func replay() {
        playbackManager.playbackMedia(callback: {
            
        }, failCallback: {
            
        })
    }
    
    func isCanPlayPrevious() -> Bool {
        if urls.count == 1 || urls.count == 0 {
            return false
        }
        if currentPlayIndex == 0 {
            return false
        }
        return true
    }
    
    func playPrevious() {
        currentPlayIndex -= 1
        if currentPlayIndex < 0 {
            return
        }
        if urls.isBoundary(index: currentPlayIndex) == false {
            playMedia(index: currentPlayIndex) {}
        }
    }
    /// 是否可以播放下一个, 是相对于当前要播放的音频的下一个, 用于判断下一个和上一个按钮是否可以使用
    func isCanPlayNext() -> Bool {
        if urls.count == 1 || urls.count == 0 {
            return false
        }
        if urls.count - 1 == currentPlayIndex {
            return false
        }
        return true
    }
    /// 播放下一个
    func playNext() {
        currentPlayIndex += 1
        if urls.isBoundary(index: currentPlayIndex) == false {
            playMedia(index: currentPlayIndex) {}
        }
    }
    func startSeekToTime() {
        if self.isPlaybackActivity {
            playbackManager.pause()
        }else {
            
        }
    }

    func seekToTime(toTime:Float, callback:(_ currentTime:TimeInterval, _ duration:TimeInterval)->Void, failure:()->Void) {
        if self.playState == .playing || self.playState == .paused {
            playbackManager.seekToTime(toTime: toTime, callback: {
                
            }) {
                
            }
        }
    }
}

extension BYMediaPlaySession : BYMediaPlaybackProtocol {
    
    func mediaPlaybackAssetUrls() -> (assetUrls: [URL], playIndex: Int) {
        return (urls, currentPlayIndex)
    }
    
    func mediaPlaybackLoadState(status: BYMediaStreamsLoadStatus) {
        
    }
    
    func mediaBufferTimeChanged(bufferTime: TimeInterval, duration: TimeInterval) {
        self.playbackSession?.mediaPlayBufferTimeChanged(bufferTime: bufferTime, duration: duration)
    }
    
    func mediaPlayTimeChanged(currentTime: TimeInterval, duration: TimeInterval) {
        self.currentTime = currentTime
        self.duration = duration
        self.playbackSession?.mediaPlayTimeChanged(currentTime: currentTime, duration: duration)
    }
    
    func mediaPlaybackState(status: BYMediaStreamsPlayStatus) {
        var playbackStatus:BYMediaPlayerPlaybackState = .failed
        switch status {
        case .failed:
            playbackStatus = .failed
            break
        case .paused:
            playbackStatus = .paused
            break
        case .playing:
            playbackStatus = .playing
            break
        case .stoped:
            playbackStatus = .stoped
            break
        case .unknown:
            playbackStatus = .unknown
            break
        case .buffering:
            playbackStatus = .buffering
        }
        playState = playbackStatus
        playbackSession?.mediaPlaybackState(playState: playState)
    }
    
    func mediaPlayCurrentPlay(index: Int) {
        playbackSession?.mediaPlayCurrentPlay(index: currentPlayIndex)
    }
    
    func mediaPlayToEndTime(index: Int) {
        self.playbackSession?.mediaPlayToEndTime(index: index)
        switch playPattern {
        case .loop:
            if self.urls.count == 1 {
                playMedia(index: 0) {}
            }else {
                self.playNext()
            }
        case .singleLoop:
            self.replay()
        case .random:
            let index = arc4random() % UInt32(self.urls.count)
            playMedia(index: NSInteger(index)) {}
        case .single:
            playState = BYMediaPlayerPlaybackState.stoped
        }
    }
    
    func mediaPlay(callback: (Bool) -> Void) {
        
    }
    
    func mediaFullScreen(callback: (Bool) -> Void) -> CGRect {
        if let frame = self.playbackSession?.mediaFullScreen(callback: callback) {
            return frame
        }
        return CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200)
    }
    
    func mediaPlayLayer(playLayer: UIView) {
        self.playbackSession?.mediaPlayLayer(playLayer: playLayer)
    }
    
}

