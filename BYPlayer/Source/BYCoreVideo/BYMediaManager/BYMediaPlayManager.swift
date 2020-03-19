//
//  BYMediaPlayManager.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
import AVFoundation

class BYMediaPlayManager: NSObject {

    static private let sharedManager = BYMediaPlayManager()
    static func shareInstance() -> BYMediaPlayManager {
        return sharedManager
    }
    private var playerLayer:BYPlayerLayer = BYPlayerLayer.init(frame: CGRect.zero)
    private let mediaStreams = BYMediaStreams.shareInstance()
    private var playContentViewFrame:CGRect = CGRect.zero {
        didSet {
            playerLayer.playContentViewFrame = playContentViewFrame
        }
    }
    private var playLoadStatus:BYMediaStreamsLoadStatus = .unknown
    
    var playState:BYMediaStreamsPlayStatus = .unknown
    var coverImage:UIImage?
    
    var playContentView:UIView? {
        didSet {
            if let layer = playContentView {
                showPlayView(playView: layer)
            }else {
                playerLayer.removeFromSuperview()
            }
        }
    }
    var isPlaying:Bool {
        get {
            return mediaStreams.isPlaying()
        }
    }
    weak var playbackProtocol:BYMediaPlaybackProtocol?
    
    private override init() {
        super.init()
        mediaStreams.mediaStreamsProtocol = self
        playerLayer.transportDelegate = self
        playerLayer.showPlayer(player: mediaStreams.player)
    }
    
    private func showPlayView(playView:UIView) {
        playContentViewFrame = playView.bounds
        playerLayer.frame = playContentViewFrame
        playView.addSubview(playerLayer)
        playerLayer.showCoverImage(coverImage: coverImage)
        /// WIFI 下自动播放, 开始加载圈圈, 非WIFI, 不自动播放, 点击播放按钮后再加载圈圈
        if MayaNetWork.network().isReachableOnWiFi {
            playerLayer.loadingLayer.isHidden = false
        }else {
            playerLayer.loadingLayer.isHidden = true
        }
    }
    
    func playbackMedia(callback:()->Void, failCallback:()->Void) {
        BYMediaStreams.shareInstance().deallocVideo = false
        let assetUrls:[URL] = playbackProtocol?.mediaPlaybackAssetUrls().assetUrls ?? []
        let playIndex:Int = playbackProtocol?.mediaPlaybackAssetUrls().playIndex ?? 0
        if assetUrls.count == 0 {
            // 播放视频结束会弹这个
            //XLToast.showToast(message: "播放资源不存在")
            failCallback()
            return
        }
        var urlAssetList:[AVURLAsset] = []
        assetUrls.forEach({ (url) in
            let urlAsset = AVURLAsset.init(url: url)
            urlAssetList.append(urlAsset)
        })
        if playIndex > urlAssetList.count - 1 {
            print("已播放到最后")
            failCallback()
            return
        }
        mediaStreams.asset = urlAssetList[playIndex]
        playbackProtocol?.mediaPlayCurrentPlay(index: playIndex)
        callback()
    }
    
    func play() {
        if mediaStreams.isPlaying() == false {
            mediaStreams.play()
        }
        playbackProtocol?.mediaPlaybackState(status: .playing)
    }
    
    func pause() {
        if mediaStreams.isPlaying() == true {
            mediaStreams.pause()
        }
        if playState == .paused || playState == .playing || playState == .buffering {
            /// 手动调用一次暂停, 因为当被打断时, 或者拔出耳机时, 系统会自动执行暂停操作, 此时mediaStreams.isPlaying()的值会自动变为暂停, 这个时候再通过打断的通知过来, 再判断状态, 已经是暂停状态mediaStreams.isPlaying() 为 false , 则不会执行 暂停操作
            playbackProtocol?.mediaPlaybackState(status: .paused)
        }
        DispatchQueue.main.async {
            self.mediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.paused)
        }
    }
    
    func handleInterruption() {
        playbackProtocol?.mediaPlaybackState(status: .paused)
    }
    
    /// 该方法是用户手动调stop
    func playStop() {
        mediaStreams.stop()
        playbackProtocol?.mediaPlaybackState(status: .stoped)
        playerLayer.playedProgress = (0,0)
        playerLayer.bufferProgress = (0,0)
        playerLayer.resetStopLayer(coverImage:coverImage)
        BYMediaStreams.shareInstance().deallocVideo = true
    }
    
    /// 该方法是自然播放完成
    private func playToEnd() {
        playbackProtocol?.mediaPlaybackState(status: .stoped)
        playerLayer.playedProgress = (0,0)
        playerLayer.bufferProgress = (0,0)
        playerLayer.resetPlayToEndLayer(coverImage:coverImage)
    }
    
    func seekToTime(toTime:Float, callback:@escaping ()->Void, failure:@escaping ()->Void) {
        mediaStreams.seekToTime(toTime: toTime, callback: {
            callback()
        }) {
            failure()
        }
    }
}

extension BYMediaPlayManager : BYMediaStreamsProtocol {
    func mediaLoadStreamsStatus(valueStatus: BYMediaStreamsLoadStatus) {
        playLoadStatus = valueStatus
        playbackProtocol?.mediaPlaybackLoadState(status: valueStatus)
    }
    
    func mediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus) {
        playState = valueStatus
        switch playState {
        case .playing:
            playerLayer.toggleBtn.isSelected = true
            playerLayer.toggleCoverImage(isHidden: true)
        default:
            playerLayer.toggleBtn.isSelected = false
        }
        if playState == .buffering || playState == .unknown || playState == .failed {
            playerLayer.loadingLayer.isHidden = false
        }else {
            playerLayer.loadingLayer.isHidden = true
        }
        playbackProtocol?.mediaPlaybackState(status: valueStatus)
    }
    
    func mediaPlayToFinished() {
        playerLayer.exitFullScreen()
        playToEnd()
        playbackProtocol?.mediaPlayToEndTime(index: playbackProtocol?.mediaPlaybackAssetUrls().playIndex ?? 0)
    }
    
    func mediaPlayTimeChange(currentTime: TimeInterval, duration: TimeInterval) {
        if playState == .paused || playState == .playing {
            playbackProtocol?.mediaPlayTimeChanged(currentTime: currentTime, duration: duration)
            playerLayer.playedProgress = (currentTime, duration)
        }
        /// 从播放列表到播放详情的续播, 有时会在正常播放过程中, 出现加载圈圈, 在此处再添加一层判断处理
        if playState == .buffering || playState == .unknown || playState == .failed {
            playerLayer.loadingLayer.isHidden = false
        }else {
            playerLayer.loadingLayer.isHidden = true
        }
        /// 从播放列表到播放详情的续播, 有时会在正常播放过程中, 出现封面图, 在此处再添加一层判断处理
        if playState == .playing {
            playerLayer.toggleCoverImage(isHidden: true)
        }
        playbackProtocol?.mediaPlayLayer(playLayer: playerLayer)
    }
    
    func mediaStremasBufferTimeChnage(bufferTime: TimeInterval, duration: TimeInterval) {
        /// 这个地方不要写缓冲的状态, 因为资源一开始加载, 设置模式是缓冲模式, 否则会出现当新的资源没加载的时候, 缓冲出现的是上个音频的进度
        if playState == .paused || playState == .playing {
            playbackProtocol?.mediaBufferTimeChanged(bufferTime: bufferTime, duration: duration)
            playerLayer.bufferProgress = (bufferTime, duration)
        }
        if playState == .buffering || playState == .unknown || playState == .failed {
            playerLayer.loadingLayer.isHidden = false
        }else {
            playerLayer.loadingLayer.isHidden = true
        }
    }
    
    func mediaStremasBufferEmpty() {
        
    }
    
    func mediaStremasBufferFull() {
        
    }
}

extension BYMediaPlayManager: BYTransportDelegate {
    
    /// 开始快进时要进行暂停, 否则如果网速不好, 进度条会跳回到原来播放的地方, 等加载到快进的地方, 进度条又跳回来
    /// 或者进行快进的时候现在进度条根据播放变动, 等加载到快进的地方再根据播放变动
    func scrubbingDidStart(value: Float) {
        pause()
    }
    func scrubbingDidEnd(value: Float) {
        seekToTime(toTime: value, callback: {
            
        }) {
            
        }
    }
    
    func transportPlay() {
        play()
    }
    
    func transportPause() {
        pause()
    }
    
    func transportStop() {
        playStop()
    }

    func fullScreen(isFull: Bool) {
        
        if let frame = playbackProtocol?.mediaFullScreen(callback: { (isFull) in
            
        }) {
            playContentViewFrame = frame
        }
    }
}
