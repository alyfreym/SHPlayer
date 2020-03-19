//
//  NetWork.swift
//  AppBanner
//
//  Created by 张义镇 on 2018/8/17.
//  Copyright © 2018年 z. All rights reserved.
//

import UIKit

enum NetWorkType {
    case NONE
    case WiFi
    case WWAN
    case ERROR
}

protocol NetWorkDelegate {
    func NetWorkStatus(type : NetWorkType)
}

final class MayaNetWork {
    
    private var reachability = Reachability()
    
    var delegate: NetWorkDelegate?
    
    static private let sharedInstance:MayaNetWork = MayaNetWork()
    static func network() -> MayaNetWork {
        return sharedInstance
    }
 
    private init() {
        netWorkStatusListener()
    }
    
    var isReachable: Bool {
        return reachability?.connection != Reachability.Connection.none
    }

    var isReachableOnWWAN: Bool {
        return reachability?.connection == .cellular
    }

    var isReachableOnWiFi: Bool {
        return reachability?.connection == .wifi
    }
    
    func netWorkStatusListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: Notification.Name.reachabilityChanged, object: reachability)
        do {
            try reachability?.startNotifier()
        }catch{
//            print("网络监听出错啦")
            delegate?.NetWorkStatus(type: .ERROR)
        }
    }

    @objc func reachabilityChanged(note : NSNotification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
            case .none:
                delegate?.NetWorkStatus(type: .NONE)
//                XLToast.showToast(message: "网络无法连接")
                break
            case .wifi:
                delegate?.NetWorkStatus(type: .WiFi)
//                XLToast.showToast(message: "当前为WiFi网络")
                break
            case .cellular:
                delegate?.NetWorkStatus(type: .WWAN)
//                XLToast.showToast(message: "当前为移动蜂窝网络")
                break
            
        }
    }
    
    
    
}
