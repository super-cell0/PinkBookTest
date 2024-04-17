//
//  TextViewAccessoryView.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/17.
//

import UIKit

class TextViewAccessoryView: UIView {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var stackViewState: UIStackView! {
        didSet {
            stackViewState.isHidden = true
        }
    }
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var maxTextCountLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var currentTextCount = 0 {
        didSet {
            if currentTextCount < kMaxTextViewText {
                doneButton.isHidden = false
                stackViewState.isHidden = true
            } else {
                doneButton.isHidden = true
                stackViewState.isHidden = false
                textCountLabel.text = "\(currentTextCount)"
            }
        }
    }

}
