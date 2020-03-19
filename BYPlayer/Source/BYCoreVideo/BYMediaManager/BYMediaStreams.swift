//
//  BYMediaStreams.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
import AVFoundation

struct BYMediaKVOProperty {
    static let assetKeysRequiredToPlay = [
        "playable",
        "hasProtectedContent"
    ]
}

final class BYMediaStreams: NSObject {
    
    static private let sharedManager = BYMediaStreams()
    static func shareInstance() -> BYMediaStreams {
        return sharedManager
    }
    var deallocVideo:Bool = false
    var playStatus:BYMediaStreamsPlayStatus = .unknown
    var asset:AVURLAsset? {
        didSet {
            if asset != nil {
                transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.buffering)
                asynchronouslyLoadURLAsset(asset!)
            }
        }
    }
    var loadObserverKVO:Bool = false
    weak var mediaStreamsProtocol:BYMediaStreamsProtocol?
    @objc let player:AVPlayer = AVPlayer()
    private var timeObserver:Any?
    private var playerItem: AVPlayerItem? = nil {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
            playerItem?.canUseNetworkResourcesForLiveStreamingWhilePaused = true
            if #available(iOS 10.0, *) {
                // 解决iOS 10 以后, 非HLS 协议视频无法播放的问题
                //Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: 'AVPlayer cannot service a synchronized playback request via setRate:time:atHostTime: when automaticallyWaitsToMinimizeStalling is YES'
                //Note that setRate:time:atHostTime: is not currently supported for HTTP Live Streaming or when automaticallyWaitsToMinimizeStalling is YES. For clients linked against iOS 10.0 and later or OS X 12.0 and later, invoking setRate:time:atHostTime: when automaticallyWaitsToMinimizeStalling is YES will raise an NSInvalidArgument exception.
                self.player.automaticallyWaitsToMinimizeStalling = false
                playerItem?.preferredForwardBufferDuration = 1
            } else {
                // Fallback on earlier versions
            }
            addObserver()
        }
    }
    
    private override init() {
        super.init()
        
        addObserver()
        self.addPlayItemTimeObserver()
        let playbackNotification = BYMediaPlayNotifcation()
        playbackNotification.player = player
        playbackNotification.notificationProtocol = self
        playbackNotification.registerPlaybackNotofication()
    }
    
}

extension BYMediaStreams {
    func playKeyPaths() -> [String] {
        if #available(iOS 10.0, *) {
            let observedKeyPaths = [
                #keyPath(BYMediaStreams.player.currentItem.status),
                #keyPath(BYMediaStreams.player.currentItem.loadedTimeRanges),
                #keyPath(BYMediaStreams.player.currentItem.seekableTimeRanges),
                #keyPath(BYMediaStreams.player.currentItem.isPlaybackBufferEmpty),
                #keyPath(BYMediaStreams.player.currentItem.isPlaybackLikelyToKeepUp),
                #keyPath(BYMediaStreams.player.currentItem.isPlaybackBufferFull),
//                #keyPath(BYMediaStreams.player.currentItem.timebase),
                #keyPath(BYMediaStreams.player.timeControlStatus)
            ]
            return observedKeyPaths
        }else {
            let observedKeyPaths = [
                #keyPath(BYMediaStreams.player.currentItem.status),
                #keyPath(BYMediaStreams.player.currentItem.loadedTimeRanges),
                #keyPath(BYMediaStreams.player.currentItem.seekableTimeRanges),
                #keyPath(BYMediaStreams.player.currentItem.isPlaybackBufferEmpty),
                #keyPath(BYMediaStreams.player.currentItem.isPlaybackLikelyToKeepUp),
//                #keyPath(BYMediaStreams.player.currentItem.timebase),
                #keyPath(BYMediaStreams.player.currentItem.isPlaybackBufferFull),
                ]
            return observedKeyPaths
        }
    }
    func addObserver() {
        if #available(iOS 10.0, *) {
            for keyPath in playKeyPaths() {
                addObserver(self, forKeyPath: keyPath, options: [.new, .initial], context: nil)
            }
        }else {
            for keyPath in playKeyPaths() {
                addObserver(self, forKeyPath: keyPath, options: [.new, .initial], context: nil)
            }
        }
        loadObserverKVO = true
    }
    
    func removeObserver() {
        if #available(iOS 10.0, *) {
            for keyPath in playKeyPaths() {
                removeObserver(self, forKeyPath: keyPath)
            }
        }else {
            for keyPath in playKeyPaths() {
                removeObserver(self, forKeyPath: keyPath)
            }
        }
        loadObserverKVO = false
    }
    
    // MARK: - Asset Loading
    private func asynchronouslyLoadURLAsset(_ newAsset: AVURLAsset) {
        newAsset.loadValuesAsynchronously(forKeys: BYMediaKVOProperty.assetKeysRequiredToPlay) {
            DispatchQueue.main.async {
                guard newAsset == self.asset else {
                    return
                }
                for key in BYMediaKVOProperty.assetKeysRequiredToPlay {
                    var error: NSError?
                    if newAsset.statusOfValue(forKey: key, error: &error) == .failed {
                        let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
                        let message = String.localizedStringWithFormat(stringFormat, key)
                        self.handleErrorWithMessage(message, error: error)
                        self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: BYMediaStreamsLoadStatus.failed)
                        return
                    }
                }
                
                // We can't play this asset.
                if !newAsset.isPlayable || newAsset.hasProtectedContent {
                    let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
                    self.handleErrorWithMessage(message)
                    self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: BYMediaStreamsLoadStatus.failed)
                    return
                }
                let avPlayerItem = AVPlayerItem(asset: newAsset)
                self.playerItem = avPlayerItem
                var error:NSError?
                let loadStatus = newAsset.statusOfValue(forKey: BYMediaKVOProperty.assetKeysRequiredToPlay.first!, error: &error)
                if loadStatus == AVKeyValueStatus.cancelled {
                    self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: .cancelled)
                }else if loadStatus == AVKeyValueStatus.failed {
                    self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: .failed)
                    BYMediaMeasuringLog.accessLog(playerItem: avPlayerItem)
                    BYMediaMeasuringLog.errorLog(playerItem: avPlayerItem)
                }else if loadStatus == AVKeyValueStatus.loaded {
                    self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: .loaded)
                }else if loadStatus == AVKeyValueStatus.loading {
                    self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: .loading)
                }else if loadStatus == AVKeyValueStatus.unknown {
                    self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: .unknown)
                }
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if deallocVideo == true {
            BYMediaLog("observeValue deallocVideo = \(deallocVideo)")
            return
        }
        if playStatus == .paused || playStatus == .stoped {
            BYMediaLog("拦截 playStatus = \(playStatus), keyPath = \(String(describing: keyPath))")
            return
        }
        BYMediaLog("放行 playStatus = \(playStatus)")
        //由于AVFoundation 没有指定在哪个线程执行status通知, 所以要确保应用程序回到主线程, 向其传递一个主队了引用
        DispatchQueue.main.async {
            guard let playItem:AVPlayerItem = (object as! BYMediaStreams).playerItem else {
                return
            }
            if keyPath == #keyPath(BYMediaStreams.player.currentItem.status) {
                if playItem.status == AVPlayerItem.Status.readyToPlay {
                    /**
                     * 暂停播放, 退到后台几分钟, 进入App, 会走这个方法, 进行判断, 如果是正在播放则进行播放, 否则不自动播放.
                     * 当资源可播放的时候, 第一步这个方法不会走, 而是等isPlaybackBufferEmpty为true是才开始真正的播放, 然后playState的状态会变为.playing, 这是如果再次走到readyToPlay, z则会执行self.play(), 这样写是从后进入前台时做了非播放状态, 不走self.play(), 否则, 就要在推入后台记录一下状态, 进入前台时再判断是否是播放时推入的后台, 有点麻烦
                     */
                    if #available(iOS 10.0, *) {
                        if BYMediaPlayManager.shareInstance().playState == .playing {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                                BYMediaLog("readyToPlay play")
                                self.play()
                            })
                        }
                    }else {
                        self.play()
                    }
                }else if playItem.status == AVPlayerItem.Status.failed {
                    self.transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.failed)
                }else if playItem.status == AVPlayerItem.Status.unknown {
                    self.transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.unknown)
                }
            }else if keyPath == #keyPath(BYMediaStreams.player.currentItem.loadedTimeRanges) {
                let bufferProgress = self.availableDuration(player: self.player)
                let duration = playItem.asset.duration
                let totalDuration = CMTimeGetSeconds(duration)
//                BYMediaLog("当前缓冲进度: \(bufferProgress)), 总共时长: \(totalDuration)")
                self.mediaStreamsProtocol?.mediaStremasBufferTimeChnage(bufferTime: bufferProgress, duration: totalDuration)
                if bufferProgress >= totalDuration {
                    BYMediaLog("缓冲完成")
                }
            }else if keyPath == #keyPath(BYMediaStreams.player.currentItem.isPlaybackBufferEmpty) {
                BYMediaLog("isPlaybackBufferEmpty = \(playItem.isPlaybackBufferEmpty)")
                if (playItem.isPlaybackBufferEmpty) {
                    //表示已经消耗了所有的缓冲数据
                    //1. 可能是缓冲数据没有缓冲完, 但是已经播放到了缓冲的地方, 不能继续播放, 此时暂停
                    //2. 可能是数据已经缓冲完了, 此时播放到了最后, 此时停止
                    self.buffering()
                    BYMediaLog("isPlaybackBufferEmpty buffering")
                    //XLToast.showToast(message: "isPlaybackBufferEmpty buffering")
                }else {
                    self.play()
                    BYMediaLog("isPlaybackBufferEmpty play")
                    //XLToast.showToast(message: "isPlaybackBufferEmpty play")
                }
            }else if keyPath == #keyPath(BYMediaStreams.player.currentItem.isPlaybackLikelyToKeepUp) {
                /**
                 * 这个如果是网络很不好的情况下, 执行了stop()之后, 发现isPlaybackLikelyToKeepUp 为 true, 这里是个坑呀
                 */
                if (playItem.isPlaybackLikelyToKeepUp) {
                    //isPlaybackLikelyToKeepUp 监听在整个播放过程中会被一直调用, 比如从播放到暂停, 从暂停到播放, 都会调用, isPlaybackLikelyToKeepUp的代表的是当前缓冲的是否可以播放, 所以, 这里不能做播放暂停的操作, 因为, 当你点击暂停时, 也会调用, 如果 isPlaybackLikelyToKeepUp 为true, 则会调用play()
                    //当在进行缓冲的时候点击暂停是无效的, 因为每次缓冲到了可以播放的内容, isPlaybackLikelyToKeepUp 为 true
                    BYMediaLog("isPlaybackLikelyToKeepUp play")
                    //XLToast.showToast(message: "isPlaybackLikelyToKeepUp play")
                }else {
                    BYMediaLog("isPlaybackLikelyToKeepUp buffering")
                    //XLToast.showToast(message: "isPlaybackLikelyToKeepUp buffering")
                }
                BYMediaLog("isPlaybackLikelyToKeepUp = \(playItem.isPlaybackLikelyToKeepUp)")
            }else if keyPath == #keyPath(BYMediaStreams.player.currentItem.isPlaybackBufferFull) {
                /// 这个值为true 时表示可以播放, 但是此时有可能会有统计数据不全, 导致播放器无法预测剩下的是否可以继续播放, 即isPlaybackLikelyToKeepUp为false
                BYMediaLog("isPlaybackBufferFull = \(playItem.isPlaybackBufferFull)")
            }else if keyPath == #keyPath(BYMediaStreams.player.currentItem.seekableTimeRanges) {
                playItem.seekableTimeRanges.forEach({ (val) in
                    BYMediaLog("val = \(val)")
                })
            }else if keyPath == #keyPath(BYMediaStreams.player.timeControlStatus) {
                if #available(iOS 10.0, *) {
                    if self.player.timeControlStatus == AVPlayer.TimeControlStatus.paused {
                        BYMediaLog("AVPlayer.TimeControlStatus.paused")
                    }else if self.player.timeControlStatus == AVPlayer.TimeControlStatus.playing {
                        BYMediaLog("AVPlayer.TimeControlStatus.playing")
                    }else if self.player.timeControlStatus == AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate {
                        BYMediaLog("AVPlayer.TimeControlStatus.waitingToPlayAtSpecifiedRate")
                    }
                }
            }
//            else if keyPath == #keyPath(BYMediaStreams.player.currentItem.timebase) {
//                if let timebase = playItem.timebase {
//                    if CMTimebaseGetRate(timebase) > 0 {
//                    }else {
//                    }
//                    BYLog("playItem.timebase = \(CMTimebaseGetRate(timebase))")
//                }
//            }
        }
    }
}

extension BYMediaStreams {
    
    func play() {
        if deallocVideo {
            BYMediaLog("play deallocVideo = \(deallocVideo)")
            return
        }
        BYMediaLog("BYMediaStreams play")
        transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.playing)
        player.play()
    }
    
    func pause() {
        BYMediaLog("BYMediaStreams pause")
        transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.paused)
        player.pause()
    }
    
    func stop() {
        BYMediaLog("BYMediaStreams stopStart")
        player.pause()
        transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.stoped)
        self.mediaStreamsProtocol?.mediaLoadStreamsStatus(valueStatus: BYMediaStreamsLoadStatus.cancelled)
        self.mediaStreamsProtocol?.mediaStremasBufferTimeChnage(bufferTime: 0, duration: 0)
        self.mediaStreamsProtocol?.mediaPlayTimeChange(currentTime: 0, duration: 0)
        BYMediaLog("BYMediaStreams stopEnd")
        if loadObserverKVO {
            removeObserver()
            BYMediaLog("BYMediaStreams removeObserver")
        }
        guard let playItem = player.currentItem else {
            return
        }
        if playItem.status == .readyToPlay {
            /// stop之后如何结束缓冲?
            // 调用cancelLoading并不能完全的取消KVO, 当网络z不好, 正在加载还没开始播放时, 如果此时调用cancelLoading, 还是会走kvo
            playItem.asset.cancelLoading()
            // Call this method only when the rate is currently zero and only after the AVPlayer's status has become AVPlayerStatusReadyToPlay.
            // 调用了这个方法好像KVO都不走了, 没有确切的文挡说明,自测没有出现KVO被调用的情况
            player.cancelPendingPrerolls()
            BYMediaLog("BYMediaStreams readyToPlay stopEnd")
            /** rate 设置非0只, 会走播放结束的通知 AVPlayerItemFailedToPlayToEndTime; 这个方法并不能改变播放器的状态,timeControlStatus的值仍然为playing
             * 设置该方法之前先设置pause(), 直接调用AVPlayer的pause(), 再调用setRate(), timeControlStatus值为pause, 调用isPlaying() 返回值就是false了
             * AVPlayer cannot service a synchronized playback request via setRate:time:atHostTime: until its status is AVPlayerStatusReadyToPlay.
             */
            player.setRate(0.0, time: CMTime.zero, atHostTime: CMTime.zero)

            if #available(iOS 10.0, *) {
                BYMediaLog("BYMediaStreams readyToPlay stopEnd = \(self.player.timeControlStatus.rawValue)")
            } else {
                
            }
            BYMediaLog("BYMediaStreams BYMediaStreamsPlayStatus = \(BYMediaStreamsPlayStatus.stoped)")
            BYMediaLog("BYMediaStreams BYMediaStreamsLoadStatus = \(BYMediaStreamsLoadStatus.cancelled)")
        }
    }
    
    /// 这个判断播放暂停的状态, 有系统来决定其状态, 比如被打断时, 会自动变为暂停, 缓冲不足也会自动变为暂停, 使用时需要注意这些情况
    func isPlaying() -> Bool {
        if #available(iOS 10.0, *) {
            return self.player.timeControlStatus == AVPlayer.TimeControlStatus.playing
        } else {
            return self.player.rate == 1
        }
    }
    
    func buffering() {
        BYMediaLog("BYMediaStreams buffering...")
        player.pause()
        transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.buffering)
    }
    
    func seekToTime(toTime:Float, callback:@escaping ()->Void, failure:@escaping ()->Void) {
        playerItem?.cancelPendingSeeks()
        let duration:TimeInterval = CMTimeGetSeconds(asset?.duration ?? CMTime.zero)
        let seekTime:CMTime = CMTimeMakeWithSeconds(Double(toTime) * duration, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: seekTime) { (isFinished) in
            if isFinished {
                callback()
                self.play()
            }else {
                failure()
            }
        }
//        player.seek(to: seekTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero) { (isFinished) in
//
//        }
    }
    
    private func transportMediaPlayStreamsStatus(valueStatus:BYMediaStreamsPlayStatus) {
        self.playStatus = valueStatus
        BYMediaLog("BYMediaStreams playStatus = \(self.playStatus)")
        DispatchQueue.main.async {
            self.mediaStreamsProtocol?.mediaPlayStreamsStatus(valueStatus: valueStatus)
        }
    }

}
extension BYMediaStreams {

    //定期监听
    private func addPlayItemTimeObserver() {
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        timeObserver = self.player.addPeriodicTimeObserver(forInterval: interval, queue:mainQueue) { [weak self]time in
            let currentTime:TimeInterval = CMTimeGetSeconds(time)
            let duration:TimeInterval = CMTimeGetSeconds(self?.playerItem?.asset.duration ?? CMTimeMake(value: 0, timescale: 0))
            self?.mediaStreamsProtocol?.mediaPlayTimeChange(currentTime: currentTime, duration: duration)
            //BYMediaLog("currentTime = \(currentTime) duration = \(duration)")
            if self!.deallocVideo {
                self?.stop()
                BYMediaLog("addPeriodicTimeObserver deallocVideo = \(self!.deallocVideo)")
            }
        }
    }
    
    private func availableDuration(player:AVPlayer) -> TimeInterval {
        guard let playItem = player.currentItem else {
            return 0
        }
        guard let timeRangesFirst = playItem.loadedTimeRanges.first else {
            return 0
        }
        // 获取缓冲区域
        let timeRange:CMTimeRange = timeRangesFirst.timeRangeValue
        let startSeconds:Float64 = CMTimeGetSeconds(timeRange.start)
        let durationSeconds:Float64 = CMTimeGetSeconds(timeRange.duration)
        // 计算缓冲总进度
        let result:TimeInterval = startSeconds + durationSeconds
        return result
    }
    
    // MARK: - Error Handling
    private func handleErrorWithMessage(_ message: String?, error: Error? = nil) {
        NSLog("Error occured with message: \(String(describing: message)), error: \(String(describing: error)).")
    }
}

extension BYMediaStreams: BYMediaPlaybackNotificationProtocol {
    func mediaFailedToPlayToEndTimeNotification() {
        transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.failed)
    }
    
    func mediaPlayStalledNotification() {
        ///在监听的tKVO里面判断 playStatus == .paused || playStatus == .stoped 时不再往下执行, 一面停止或者暂停后, 由于缓冲的原因, 继续往下执行, 当进行停止之后, 执行 player.setRate(0.0, time: CMTime.zero, atHostTime: CMTime.zero) 之后, 会再次自行这个通知, 由于这个通知会把状态改为buffer, 所以, 监听的判断就失效了.//        self.buffering()
    }
    
    func mediaPlayToEndTimeNotification() {
        self.player.seek(to: CMTime.zero)
        transportMediaPlayStreamsStatus(valueStatus: BYMediaStreamsPlayStatus.stoped)
        self.mediaStreamsProtocol?.mediaPlayToFinished()
    }
    
}

