//
//  WaterfallCollectionViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import CHTCollectionViewWaterfallLayout
import XLPagerTabStrip


class WaterfallCollectionViewController: UICollectionViewController, CHTCollectionViewDelegateWaterfallLayout, IndicatorInfoProvider {
    
    var channel = ""
    let photos = [UIImage(named: "batman")!, UIImage(named: "codeman")!]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = collectionView.collectionViewLayout as! CHTCollectionViewWaterfallLayout
        layout.columnCount = 2
        layout.minimumColumnSpacing = 4
        layout.minimumInteritemSpacing = 4
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 4, right: 4)
        layout.itemRenderDirection = .leftToRight

    }


    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kWatefallCellID, for: indexPath) as! WaterfallCollectionViewCell
    
        cell.imageView.image = photos[indexPath.item]
    
        return cell
    }


}

extension WaterfallCollectionViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return photos[indexPath.item].size
    }

}

extension WaterfallCollectionViewController {
    
    func indicatorInfo(for pagerTabStripController: XLPagerTabStrip.PagerTabStripViewController) -> XLPagerTabStrip.IndicatorInfo {
    return IndicatorInfo(title: channel)
    }

}
