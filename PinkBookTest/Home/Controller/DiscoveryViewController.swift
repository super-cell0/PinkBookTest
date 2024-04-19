//
//  DiscoveryViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import XLPagerTabStrip

class DiscoveryViewController: ButtonBarPagerTabStripViewController, IndicatorInfoProvider {
    

    override func viewDidLoad() {
        
        settings.style.selectedBarBackgroundColor = .mainColor
        settings.style.selectedBarHeight = 0
        
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 14)

        super.viewDidLoad()
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.secondaryLabel
            newCell?.label.textColor = UIColor.mainColor
        }
        containerView.bounces = false


    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        var vcs: [UIViewController] = []
        for channel in kChannels {
            let vc = storyboard!.instantiateViewController(identifier: kWaterfallCollectionViewControllerID) as! WaterfallCollectionViewController
            vc.channel = channel
            vcs.append(vc)
        }
        
        return vcs
    }

    


}

extension DiscoveryViewController {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "发现")
    }

}
