//
//  BYPlayerLayer.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/2.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
import AVFoundation

protocol BYTransportDelegate: NSObjectProtocol {
    func transportPlay()
    func transportPause()
    func transportStop()
    func scrubbingDidStart(value:Float)
    func scrubbedToTime(value:Float)
    func scrubbingDidEnd(value:Float)
    func jumpedToTime(value:Float)
    func fullScreen(isFull:Bool)
}

extension BYTransportDelegate {
    func scrubbingDidStart(value:Float) {}
    func scrubbedToTime(value:Float) {}
    func jumpedToTime(value:Float) {}
}

/**
 * AVPlayerLayer 只创建一个, 当播放结束或者暂停, 不移除AVPlayerLayer, 而是创建一个封面图盖在上面
 */
class BYPlayerLayer: UIView {
    
    weak var mediaStreamsProtocol:BYMediaStreamsProtocol?
    weak var transportDelegate:BYTransportDelegate?
    var isFullScreen:Bool = false
    let toggleBtn:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
    let sliderLayer:BYSliderLayer = BYSliderLayer.init(frame: CGRect.zero)
    private let maskControl:UIControl = UIControl()
    private let coverImageView:UIImageView = UIImageView()
    let loadingLayer:BYLoadingLayer = BYLoadingLayer.init(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
//    private let exitFullScreenBtn:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
    var playContentViewFrame:CGRect = CGRect.zero
    var bufferProgress:(current:TimeInterval, total:TimeInterval) = (0,0) {
        didSet {
            if bufferProgress.total > 0 {
                sliderLayer.bufferProgress = Float(bufferProgress.current / bufferProgress.total)
            }else {
                sliderLayer.bufferProgress = 0
            }
        }
    }
    
    var playedProgress:(current:TimeInterval, total:TimeInterval) = (0,0) {
        didSet {
            sliderLayer.playedProgress = playedProgress
        }
    }
    
    override class var layerClass : AnyClass {
        return AVPlayerLayer.self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
        coverImageView.frame = self.bounds
        coverImageView.image = UIImage.init(named: "xl_image_place")
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        self.addSubview(coverImageView)
        
        maskControl.addTarget(self, action: #selector(fadeInOut(_:)), for: UIControl.Event.touchUpInside)
        maskControl.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.addSubview(maskControl)
        // loadingLayer 放在 toggleBtn下面, 否则加载过程无法点击toggleBtn
        maskControl.addSubview(loadingLayer)

        toggleBtn.setImage(UIImage.init(named:"by_video_pause"), for: UIControl.State.normal)
        toggleBtn.setImage(UIImage.init(named:"by_video_play"), for: UIControl.State.selected)
        toggleBtn.addTarget(self, action: #selector(pauseAction(_:)), for: UIControl.Event.touchUpInside)
        maskControl.addSubview(toggleBtn)

        
        maskControl.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        maskControl.addSubview(sliderLayer)
        sliderLayer.slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        sliderLayer.slider.addTarget(self, action: #selector(sliderDidStart(_:)), for: UIControl.Event.touchDown)
        sliderLayer.slider.addTarget(self, action: #selector(sliderDidEnd(_:)), for: UIControl.Event.touchUpInside)
        sliderLayer.slider.addTarget(self, action: #selector(sliderOutside(_:)), for: UIControl.Event.touchUpOutside)
        
        sliderLayer.fullScreenBtn.addTarget(self, action: #selector(enterFullScreen(_:)), for: UIControl.Event.touchUpInside)
        
//        exitFullScreenBtn.setImage(UIImage.init(named: "xl_back_white_mask"), for: UIControl.State.normal)
//        exitFullScreenBtn.addTarget(self, action: #selector(exitFullScreen(_:)), for: UIControl.Event.touchUpInside)
//        exitFullScreenBtn.backgroundColor = UIColor.red
//        exitFullScreenBtn.frame = CGRect.init(x: 0, y: 0, width: 100, height: 80)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverImageView.frame = self.bounds
        maskControl.frame = self.bounds
        toggleBtn.frame = maskControl.bounds.insetBy(dx: maskControl.bounds.size.width / 2 - 25, dy: maskControl.bounds.size.height / 2 - 25)
        loadingLayer.frame = maskControl.bounds.insetBy(dx: maskControl.bounds.size.width / 2 - 25, dy: maskControl.bounds.size.height / 2 - 25)
        if BYMediaDevice.isIphoneX() && isFullScreen {
            sliderLayer.frame = self.maskControl.bounds.inset(by: UIEdgeInsets.init(top: self.maskControl.bounds.size.height - 30, left: 20, bottom: 0, right: 20))
        }else {
            sliderLayer.frame = self.maskControl.bounds.inset(by: UIEdgeInsets.init(top: self.maskControl.bounds.size.height - 30, left: 0, bottom: 0, right: 0))
        }
    }
    
    func showCoverImage(coverImage:UIImage?) {
        coverImageView.image = coverImage
        toggleCoverImage(isHidden: false)
    }
    
    func toggleCoverImage(isHidden:Bool) {
        self.coverImageView.isHidden = isHidden
    }
    
    func resetStopLayer(coverImage:UIImage?) {
//        showCoverImage(coverImage: UIImage.init(named: "xl_image_place")!)
        sliderLayer.isHidden = false
        toggleBtn.isHidden = false
        maskControl.isSelected = true
        maskControl.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    func resetPlayToEndLayer(coverImage:UIImage?) {
//        showCoverImage(coverImage: coverImage)
        sliderLayer.isHidden = false
        toggleBtn.isHidden = false
        maskControl.isSelected = true
        maskControl.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
    func showPlayer(player:AVPlayer) {
        (self.layer as! AVPlayerLayer).player = player
    }
    
}

extension BYPlayerLayer {
    @objc func pauseAction(_ btn:UIButton) {
        btn.isSelected = !btn.isSelected
        if btn.isSelected {
            self.transportDelegate?.transportPlay()
        }else {
            self.transportDelegate?.transportPause()
        }
    }
    
    @objc func sliderValueChanged(_ slider:UISlider) {
        transportDelegate?.scrubbedToTime(value: slider.value)
    }
    
    @objc func sliderDidStart(_ slider:UISlider) {
        transportDelegate?.scrubbingDidStart(value: slider.value)
    }
    
    @objc func sliderDidEnd(_ slider:UISlider) {
        transportDelegate?.scrubbingDidEnd(value: slider.value)
    }
    
    @objc func sliderOutside(_ slider:UISlider) {
        transportDelegate?.scrubbingDidEnd(value: slider.value)
    }
    
    @objc func fadeInOut(_ control:UIControl) {
        control.isSelected = !control.isSelected
        if control.isSelected {
            control.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            sliderLayer.isHidden = false
            toggleBtn.isHidden = false
        }else {
            control.backgroundColor = UIColor.black.withAlphaComponent(0)
            self.sliderLayer.isHidden = true
            toggleBtn.isHidden = true
        }
    }
}

extension BYPlayerLayer {
    
    @objc func enterFullScreen(_ btn:UIButton) {
        btn.isSelected = !btn.isSelected
        isFullScreen = btn.isSelected
        transportDelegate?.fullScreen(isFull: isFullScreen)
        if btn.isSelected {
            //self.addSubview(exitFullScreenBtn)
            sliderLayer.fullScreenBtn.isSelected = true
            let keyWindow = UIApplication.shared.keyWindow!
            self.frame = playContentViewFrame
            keyWindow.addSubview(self)

            let fullVC = BYFullScreenController()
            fullVC.modalPresentationStyle = .fullScreen
            let rootVC = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController)!
           
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi / 2))
                self.frame = CGRect.init(x: 0, y: 0, width: keyWindow.frame.size.width, height: keyWindow.frame.size.height)
                self.layoutSubviews()
            }) { (isFinished) in
                rootVC.present(fullVC, animated: false, completion: {

                })
            }
        }else {
            exitFullScreen()
        }
    }
    
    @objc func exitFullScreen() {
       
        func exitScreen() {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0) {
                self.isFullScreen = false
                //exitFullScreenBtn.removeFromSuperview()
                self.sliderLayer.fullScreenBtn.isSelected = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.transform = CGAffineTransform.identity
                    self.frame = self.playContentViewFrame
                    self.maskControl.frame = self.playContentViewFrame
                    self.layoutSubviews()
                }) { (isFinished) in
                    if let playView = BYMediaPlayManager.shareInstance().playContentView {
                        self.frame = playView.bounds
                        self.maskControl.frame = self.bounds
                        playView.addSubview(self)
                    }
                }
            }
        }
        let rootVC = ((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController)!
        rootVC.presentedViewController?.dismiss(animated: false, completion: {
        })
        exitScreen()
    }
}
