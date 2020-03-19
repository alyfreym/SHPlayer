//
//  BYMediaHuYaCell.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/15.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYMediaHuYaCell: UITableViewCell {

    var picView:UIImageView = UIImageView()
    var playBtn:UIButton = UIButton.init(type: UIButton.ButtonType.custom)
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        picView = UIImageView.init(frame: self.frame)
        picView.contentMode = .scaleAspectFill
        picView.clipsToBounds = true
        self.addSubview(picView)
        playBtn.frame = CGRect.init(x: 0, y: 0, width: 50, height: 50)
        playBtn.center = self.center
        playBtn.isUserInteractionEnabled = false
        self.addSubview(playBtn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        picView.frame = self.bounds
    }
    
    class func createWithTableViewCell(tableView:UITableView) -> UITableViewCell {
        let classString =  String(describing: BYMediaHuYaCell.self)
        var cell = tableView.dequeueReusableCell(withIdentifier: classString)
        if cell == nil {
            cell = BYMediaHuYaCell.init(style: .default, reuseIdentifier: classString)
        }
        return cell!
    }

}
