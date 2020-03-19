//
//  BYMediaMeasuringLog.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/16.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
import AVFoundation

class BYMediaMeasuringLog: NSObject {
    
    class func accessLog(playerItem:AVPlayerItem) {
        var totalDurationWatched = 0.0
        if let accessLog:AVPlayerItemAccessLog = playerItem.accessLog() {
            for event:AVPlayerItemAccessLogEvent in accessLog.events {
                if event.durationWatched > 0 {
                    totalDurationWatched += event.durationWatched
                }
                BYMediaLog("totalDurationWatched = \(totalDurationWatched)")
                BYLog("视频播放启动时间 = \(event.startupTime)")
            }
        }
    }
    
    class func errorLog(playerItem:AVPlayerItem) {
        print("playerItem.error = \(String(describing: playerItem.error))")
        if let errorLog:AVPlayerItemErrorLog = playerItem.errorLog() {
            for event:AVPlayerItemErrorLogEvent in errorLog.events {
                BYLog("视频播放出现错误: date = \(String(describing: event.date))\n uri = \(String(describing: event.uri))\n serverAddress = \(String(describing: event.serverAddress))\n playbackSessionID = \(String(describing: event.playbackSessionID))\n errorStatusCode = \(event.errorStatusCode)\n errorDomain = \(event.errorDomain)\n errorComment = \(String(describing: event.errorComment))")
            }
        }
    }
}
