//
//  BYMediaDouYinController.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/15.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYMediaDouYinController: UIViewController {

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        let cltView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height), collectionViewLayout: layout)
        cltView.delegate = self
        cltView.dataSource = self
        return cltView
    }()
    
    private var willDisplayCell:UICollectionViewCell?
    private var willDisplayCellIndex = 0
    private var didEndDisplayingCellIndex = 0
    private var dataSource:[(String, String)] = []
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var count = 0
        repeat {
            BYMediaDataSource.dataSource.forEach { (data) in
                dataSource.append(data)
            }
            print(count)
            count += 1
        }while count < 100
        
        dataSource.forEach { (tuple) in
//            BYLoadImage.loadOriginImageWithPlaceholder(imageView: UIImageView(), url: tuple.1)
        }
//        self.fd_prefersNavigationBarHidden = true
        collectionView.isPagingEnabled = true
        self.view.addSubview(collectionView)
        collectionView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        BYMediaPlaySession.playSession().playPattern = .singleLoop
    }
    deinit {
        BYMediaPlaySession.playSession().playPattern = .single
        BYMediaPlaySession.playSession().stopVideo()
    }
}

extension BYMediaDouYinController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:BYMediaDouYinCell = BYMediaDouYinCell.createCollectionViewCell(collectionView: collectionView, indexPath: indexPath) as! BYMediaDouYinCell
        cell.backgroundColor = BYMediaColor.randomColor()
//        cell.picView.image = BYLoadImage.getImageFromCache(imageUrl: dataSource[indexPath.row].1, imageType: BYLoadImageType.origin)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("willDisplay = \(indexPath.row)")
        /// 只有第一次进来才会两个值同时为0
        if willDisplayCellIndex == 0 && didEndDisplayingCellIndex == 0 {
            let sourceModel = dataSource[0]
//            BYMediaPlaySession.playSession().coverImage = BYLoadImage.getImageFromCache(imageUrl: sourceModel.1, imageType: BYLoadImageType.origin)
            BYMediaPlaySession.playSession().mediaId = sourceModel.0
            BYMediaPlaySession.playSession().assetURLs(assetURLs: [URL.init(string: sourceModel.0)!], playIndex: 0)
            BYMediaPlaySession.playSession().playVideo(contentView: cell)
        }
        willDisplayCell = cell
        willDisplayCellIndex = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("didEndDisplaying = \(indexPath.row)")
        didEndDisplayingCellIndex = indexPath.row
        /// 如果将要展示的视频没有最终展示出来, 则将要展示的index和最终展示的index是同一个值
        if didEndDisplayingCellIndex == willDisplayCellIndex {
            return
        }
        /// 结束展示时, 开始去播放将要展示的视频
        BYMediaPlaySession.playSession().stopVideo()
        let sourceModel = dataSource[willDisplayCellIndex]
//        BYMediaPlaySession.playSession().coverImage = BYLoadImage.getImageFromCache(imageUrl: sourceModel.1, imageType: BYLoadImageType.origin)
        BYMediaPlaySession.playSession().mediaId = sourceModel.0
        BYMediaPlaySession.playSession().assetURLs(assetURLs: [URL.init(string: sourceModel.0)!], playIndex: 0)
        BYMediaPlaySession.playSession().playVideo(contentView: willDisplayCell!)
    }

}
