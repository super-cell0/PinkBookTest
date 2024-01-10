//
//  FollowViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import XLPagerTabStrip

class FollowViewController: UIViewController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    


}

extension FollowViewController {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "关注")
    }

}


