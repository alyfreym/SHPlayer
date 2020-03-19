//
//  BYMediaFullScreen.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/9.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYMediaManager: NSObject {
    
    /// 由于某些页面在viewWillDisappeara方法内设置了视频暂停的设置, 当全屏的时候, 由于会模态出来一个BYFullScreenController来达到隐藏电池栏的效果, 所以会导致当前播放视频的控制器调用viewWillDisappear, 来执行pause, 所以, 再次坐下判断, 如果模态出来的控制器是BYFullScreenController, 则不执行pause
    class func viewWillDisappear() {
        let rootVC = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController)!
        if let presentVc = rootVC.presentedViewController {
            if presentVc.isKind(of: BYFullScreenController.classForCoder()) {
                
            }else {
                BYMediaPlaySession.playSession().pauseVideo()
            }
        }else {
            BYMediaPlaySession.playSession().pauseVideo()
        }
    }

}
