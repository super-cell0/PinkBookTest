//
//  PhotoFooter.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/8.
//

import UIKit

class PhotoFooter: UICollectionReusableView {
    
    @IBOutlet weak var footerAddButton: UIButton!
    
    override func awakeFromNib() {
        footerAddButton.layer.cornerRadius = 10
        footerAddButton.layer.borderWidth = 1
        footerAddButton.layer.borderColor = UIColor.quaternaryLabel.cgColor
    }
    
}
