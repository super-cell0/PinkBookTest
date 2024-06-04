//
//  NearByViewController.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit
import XLPagerTabStrip

class NearByViewController: UIViewController, IndicatorInfoProvider {
    
    lazy var testImage: UIImageView = {
        let image = UIImageView(frame: CGRect(x: 16, y: 44, width: 300, height: 300))
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let url = "https://cs193p.sites.stanford.edu/sites/g/files/sbiybj16636/files/styles/breakpoint_2xl_2x/public/media/image/homepage-default_banner.jpg.webp?itok=4QLEt1_i"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(testImage)
        
        showLoadHUD()
        DispatchQueue.global().async {
            let data = try! Data(contentsOf: URL(string: self.url)!)
            let image = UIImage(data: data)!
            
            DispatchQueue.main.async {
                self.testImage.image = image
                self.hideLoadHUD()
            }

        }

    }
    

}


extension NearByViewController {
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "附近")
    }

}
