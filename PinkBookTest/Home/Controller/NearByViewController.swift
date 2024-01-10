//
//  NearByViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import XLPagerTabStrip

class NearByViewController: UIViewController, IndicatorInfoProvider {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}


extension NearByViewController {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "附近")
    }

}
