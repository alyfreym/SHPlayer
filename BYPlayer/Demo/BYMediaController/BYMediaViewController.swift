//
//  BYMediaViewController.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/15.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYMediaViewController: UITableViewController {

    let nameList = ["抖音样式", "微博样式", "虎牙样式"]
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let douyin = BYMediaDouYinController()
            self.navigationController?.pushViewController(douyin, animated: true)
        }else if indexPath.row == 1 {
            let huya = BYMediaWeiBoController()
            self.navigationController?.pushViewController(huya, animated: true)
        }else if indexPath.row == 2 {
            let huya = BYMediaHuYaController()
            self.navigationController?.pushViewController(huya, animated: true)
        }
    }

}
