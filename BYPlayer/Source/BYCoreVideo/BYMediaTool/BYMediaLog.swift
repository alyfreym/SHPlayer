//
//  BYMediaLog.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/15.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

//public func print(_ items: Any..., separator: String = default, terminator: String = default)

func BYMediaLog(_ object:Any) {
    #if DEBUG
    print("比优心理: \(object)")
    #else
    //    print("比优心理: \(object)")
    #endif
}
