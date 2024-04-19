//
//  ChannelViewController.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/18.
//

import UIKit
import XLPagerTabStrip


protocol ChannelViewControllerDelegate {
    ///用户选者话题返回编辑页面反向传值
    /// - Parameter channel: channel标签
    /// - Parameter subChannel: subChannel话题标签
    func updateChannel(channel: String, subChannel: String)
}

class ChannelViewController: ButtonBarPagerTabStripViewController {
    
    var channelDelegate: ChannelViewControllerDelegate?

    override func viewDidLoad() {
        
        settings.style.selectedBarBackgroundColor = .mainColor
        settings.style.selectedBarHeight = 3
        
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.buttonBarItemTitleColor = .label
        settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16)
        settings.style.buttonBarItemLeftRightMargin = 0
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        
        super.viewDidLoad()
        
        containerView.bounces = false
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.secondaryLabel
            newCell?.label.textColor = UIColor.mainColor
        }


    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        var vcs: [UIViewController] = []
        for i in kChannels.indices {
            let vc = storyboard!.instantiateViewController(identifier: kChannelTableViewControllerID) as! ChannelTableViewController
            vc.channel = kChannels[i]
            vc.subChannels = kAllSubChannels[i]
            vcs.append(vc)
        }
        return vcs
    }
    

}
