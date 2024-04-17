//
//  LimitedTextView.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/17.
//

import Foundation


class LimitedTextView: UITextView {
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var placeholderAttributeds: [NSAttributedString.Key: Any]?
    
    @IBInspectable var maximumLength: Int = 0
    
    override var text: String! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialization()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        initialization()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsDisplay()
    }
    
    private func initialization() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewTextDidChange(sender:)), name: UITextView.textDidChangeNotification, object: nil)
        
    }
    
    @objc private func textViewTextDidChange(sender: Notification) {
        
        let string = text ?? ""
        
        if (maximumLength > 0), string.count > maximumLength {
            
            let selectedRange: UITextRange? = markedTextRange
            let tempSelectedTextRange = selectedTextRange
            if selectedRange == nil {
                
                let substring = string.prefix(maximumLength)
                
                text = String(substring)
                selectedTextRange = tempSelectedTextRange
            }
        }
        
        setNeedsDisplay()
        
    }
    
    override func draw(_ rect: CGRect) {
        
        guard !hasText else { return }
        
        var aRect: CGRect = .zero
        
        aRect.origin.x = textContainerInset.left + textContainer.lineFragmentPadding
        aRect.origin.y = textContainerInset.top
        aRect.size = CGSize(width: textContainer.size.width - textContainer.lineFragmentPadding, height: textContainer.size.height)
        
        let string = placeholder as NSString
        var attributes: [NSAttributedString.Key : Any]
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment
        
        if let placeholderAttributeds = placeholderAttributeds {
            var temp = placeholderAttributeds
            temp[.paragraphStyle] = style
            attributes = temp
        } else {
            attributes = [.font: font ?? UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor.lightGray, .paragraphStyle: style]
        }
        string.draw(in: aRect, withAttributes: attributes)

    }
}

