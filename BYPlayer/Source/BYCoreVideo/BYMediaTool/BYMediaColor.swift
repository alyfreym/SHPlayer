//
//  BYMediaColor.swift
//  BiYou
//
//  Created by 王腾飞 on 2018/7/13.
//  Copyright © 2018年 比优心理. All rights reserved.
//

import UIKit

class BYMediaColor: NSObject {
    
    static let color0062FF = BYMediaColor.getColor(hex: "0062FF")
    static let colorEFEFEF = BYMediaColor.getColor(hex: "EFEFEF")
    static let color01BBB6 = BYMediaColor.getColor(hex: "01BBB6")
    static let colorE5CE9D = BYMediaColor.getColor(hex: "E5CE9D")
    static let colorE5B47D = BYMediaColor.getColor(hex: "E5B47D")
    static let color000000 = BYMediaColor.getColor(hex: "000000")
    static let color000000_0_5 = BYMediaColor.getColor(hex: "7F7F7F")
    static let color000000_0_2 = BYMediaColor.getColor(hex: "CCCCCC")
    static let colorFFFFFF = BYMediaColor.getColor(hex: "FFFFFF")
    static let colorF1F1F2 = BYMediaColor.getColor(hex: "F1F1F2")
    static let color4B85EC = BYMediaColor.getColor(hex: "4B85EC")
    static let color38A9C9 = BYMediaColor.getColor(hex: "38A9C9")
    static let colorF5A623 = BYMediaColor.getColor(hex: "F5A623")
    static let color4A90E2 = BYMediaColor.getColor(hex: "4A90E2")
    static let color4A4A4A = BYMediaColor.getColor(hex: "4A4A4A")
    static let colorCCCCCC = BYMediaColor.getColor(hex: "CCCCCC")
    static let color4687DF = BYMediaColor.getColor(hex: "4687DF")
    static let colorF7F7F7 = BYMediaColor.getColor(hex: "F7F7F7")
    static let colorE1E1E1 = BYMediaColor.getColor(hex: "E1E1E1")
    static let color6E9BFF = BYMediaColor.getColor(hex: "6E9BFF")

    class func getMainColor() -> UIColor {
        return color0062FF
    }
    
    class func getMianBgcColor() -> UIColor {
        return colorEFEFEF
    }
    
    class func getColor(hex:String) -> UIColor {
        
        return UIColor.init(hex: hex)
    }
    
    class func randomColor() -> UIColor {
        return UIColor.init(red: (CGFloat(arc4random_uniform(256)) / CGFloat(255)), green: (CGFloat(arc4random() % 256) / CGFloat(255)), blue: (CGFloat(arc4random() % 256) / CGFloat(255)), alpha: 1.0)
    }
    
    class func colorRGB(red:CGFloat, green:CGFloat, blue:CGFloat) -> UIColor {
        return UIColor.init(red: red / CGFloat(255), green: green / CGFloat(255), blue: blue / CGFloat(255), alpha: 1.0)
    }
}


public extension UIColor {
  /// Constructing color from hex string
  ///
  /// - Parameter hex: A hex string, can either contain # or not
  convenience init(hex string: String) {
    var hex = string.hasPrefix("#")
      ? String(string.dropFirst())
      : string
    guard hex.count == 3 || hex.count == 6
      else {
        self.init(white: 1.0, alpha: 0.0)
        return
    }
    if hex.count == 3 {
      for (index, char) in hex.enumerated() {
        hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
      }
    }
    
    self.init(
      red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
      green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
      blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
  }
}
