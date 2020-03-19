//
//  BYSliderLayer.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/3.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYSliderLayer: UIView {

    let slider = UISlider.init()
    private let progressView:UIProgressView = UIProgressView.init(progressViewStyle: UIProgressView.Style.default)
    private let playedTimelbl:UILabel = UILabel()
    private let expectedTimelbl:UILabel = UILabel()
    let fullScreenBtn:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
    var bufferProgress:Float = 0 {
        didSet {
            progressView.progress = bufferProgress
        }
    }
    
    private var xlValue: Float = 0 {
        didSet {
            self.slider.value = xlValue
            let image = UIImage.imageWithColor(UIColor(hex: "6E9BFF"))
            self.slider.setMinimumTrackImage(image, for: .normal)
        }
    }
    
    var playedProgress:(current:TimeInterval, total:TimeInterval)! {
        didSet {
            if playedProgress.total != 0 {
                let currentMinute = String(format: "%02d", Int(playedProgress.current) / 60)
                let currentSecond = String(format: "%02d", Int(playedProgress.current) % 60)
                playedTimelbl.text = "\(currentMinute):\(currentSecond)"
                let totalMinute = String(format: "%02d", Int(playedProgress.total) / 60)
                let totalSecond = String(format: "%02d", Int(playedProgress.total) % 60)
                expectedTimelbl.text = "\(totalMinute):\(totalSecond)"
                
                slider.value = Float(playedProgress.current / playedProgress.total)
            }else {
                playedTimelbl.text = "--:--"
                expectedTimelbl.text = "--:--"
                slider.value = Float(playedProgress.current / playedProgress.total)
            }
            xlValue = Float(playedProgress.current / playedProgress.total)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressView.progressTintColor = BYMediaColor.color000000_0_2
        progressView.trackTintColor = BYMediaColor.colorEFEFEF
        progressView.progress = 0
        self.addSubview(progressView)
        
        self.slider.isContinuous = true
        self.slider.setThumbImage(UIImage(named: "xl_fm_finger"), for: .normal)
        self.slider.setThumbImage(UIImage(named: "xl_fm_finger"), for: .highlighted)
//        self.slider.currentThumbImage
        self.slider.maximumTrackTintColor = UIColor.clear
        self.slider.value = 0
        self.addSubview(slider)
        
        playedTimelbl.text = "--:--"
        playedTimelbl.font = UIFont.boldSystemFont(ofSize: 10)
        playedTimelbl.textColor = UIColor.white
        playedTimelbl.textAlignment = .center
        self.addSubview(playedTimelbl)
        
        expectedTimelbl.font = UIFont.boldSystemFont(ofSize: 10)
        expectedTimelbl.textColor = UIColor.white
        expectedTimelbl.textAlignment = .center
        expectedTimelbl.text = "--:--"
        self.addSubview(expectedTimelbl)
        
        fullScreenBtn.setImage(UIImage.init(named: "by_full_screen"), for: UIControl.State.normal)
        fullScreenBtn.setImage(UIImage.init(named: "by_exit_full_screen"), for: UIControl.State.selected)
        self.addSubview(fullScreenBtn)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playedTimelbl.frame = CGRect.init(x: 0, y: 0, width: 50, height: frame.size.height)
        progressView.frame = CGRect.init(x: playedTimelbl.frame.maxX, y: (self.frame.size.height - 2) / 2, width: frame.width - 100 - frame.size.height - 5, height: 2)
        slider.frame = CGRect.init(x: playedTimelbl.frame.maxX - 2, y: 0, width: progressView.frame.width + 2, height: self.frame.size.height)
        expectedTimelbl.frame = CGRect.init(x: slider.frame.maxX, y: 0, width: 50, height: frame.size.height)
        fullScreenBtn.frame = CGRect.init(x: expectedTimelbl.frame.maxX, y: 0, width: frame.size.height, height: frame.size.height)
        fullScreenBtn.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 5, bottom: 5, right: 5)

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
