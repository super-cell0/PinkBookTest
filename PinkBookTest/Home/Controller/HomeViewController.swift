//
//  HomeViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import XLPagerTabStrip

//1 页面继承 ButtonBarPagerTabStripViewController
//2 storyboard 的collection 指定buttonBarView
class HomeViewController: ButtonBarPagerTabStripViewController {

    override func viewDidLoad() {
        
        setTabBar()
        super.viewDidLoad()
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.secondaryLabel
            newCell?.label.textColor = UIColor.mainColor
        }
        
        containerView.bounces = false
        
    }
    
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let followVC = self.storyboard!.instantiateViewController(identifier: kFollowVCID)
        let discoveryVC = self.storyboard!.instantiateViewController(identifier: kDiscoveryVCID)
        let nearByVC = self.storyboard!.instantiateViewController(identifier: kNearyByVCID)
        
        return [discoveryVC, followVC, nearByVC]
        
    }
    
    
    func setTabBar() {
        //bar下面的条
        settings.style.selectedBarBackgroundColor = .mainColor
        settings.style.selectedBarHeight = 3
        
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemTitleColor = .label
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16)
        settings.style.buttonBarItemLeftRightMargin = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        
    }
    

}
