//
//  BYMediaHuYaController.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/15.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit
/**
 * 虎牙视频播放, 小窗模式
 */
class BYMediaHuYaController: UITableViewController {
    private var dataSource:[(String, String)] = []
    private var playCell:BYMediaHuYaCell?
    private var playContentView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = BYMediaDataSource.dataSource
        
        BYMediaPlaySession.playSession().playbackSession = self
    }
    deinit {
        BYMediaPlaySession.playSession().stopVideo()
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BYMediaHuYaCell = BYMediaHuYaCell.createWithTableViewCell(tableView: tableView) as! BYMediaHuYaCell
        cell.picView.image = UIImage.init(named: "cover")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let index = dataSource.firstIndex(where: { (model) -> Bool in
            return model.0 == BYMediaPlaySession.playSession().mediaId
        }) {
            if index == indexPath.section {
//                BYMediaPlaySession.playSession().stopVideo()
//                BYMediaPlaySession.playSession().removePlayLayer()
                playContentView.frame = CGRect.init(x: UIScreen.main.bounds.size.width - 210, y: 300, width: 200, height: 100)
                UIApplication.shared.delegate?.window!?.addSubview(playContentView)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sourceModel = dataSource[indexPath.section]
        BYMediaPlaySession.playSession().stopVideo()
        BYMediaPlaySession.playSession().coverImage = UIImage.init(named: "cover")
        BYMediaPlaySession.playSession().mediaId = sourceModel.0
        BYMediaPlaySession.playSession().assetURLs(assetURLs: [URL.init(string: sourceModel.0)!], playIndex: 0)
        let cell = tableView.cellForRow(at: indexPath)
        BYMediaPlaySession.playSession().playVideo(contentView: cell!)
        playCell = cell as? BYMediaHuYaCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 10
    }
}
extension BYMediaHuYaController: BYMediaPlaySessionProtocol {
    func mediaFullScreen(callback: (Bool) -> Void) -> CGRect {
        if let cell = playCell {
            let window = (UIApplication.shared.delegate as! AppDelegate).window!
            let tempFrame = cell.convert(cell.picView.frame, to: window)
            return tempFrame
        }
        return CGRect.zero
    }
    
    func mediaPlayLayer(playLayer: UIView) {
        playContentView = playLayer
    }
    
    func mediaPlayToEndTime(index: Int) {
        playContentView.removeFromSuperview()
    }
}
