//
//  BYFullScreenController.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/10.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYFullScreenController: UIViewController {

    /// statusBar 显示隐藏 https://blog.csdn.net/a619668402/article/details/81938083
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
