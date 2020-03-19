//
//  BYMediaDouYinCell.swift
//  BiYou
//
//  Created by 王腾飞 on 2019/1/15.
//  Copyright © 2019 比优心理. All rights reserved.
//

import UIKit

class BYMediaDouYinCell: UICollectionViewCell {

    var picView:UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        picView = UIImageView.init(frame: self.frame)
        picView.contentMode = .scaleAspectFill
        picView.clipsToBounds = true
        self.addSubview(picView)
        
        self.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        picView.frame = self.bounds
    }
    
    class func createCollectionViewCell(collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell {
        let classString =  String(describing: BYMediaDouYinCell.self)
        collectionView.register(BYMediaDouYinCell.classForCoder(), forCellWithReuseIdentifier: classString)
        return collectionView.dequeueReusableCell(withReuseIdentifier: classString, for: indexPath)
    }

}
