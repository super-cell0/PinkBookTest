//
//  Extensions.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/9.
//

import Foundation
import DateToolsSwift


extension String {
    var isBlank: Bool {
        self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension Optional where Wrapped == String {
    var unWrappedText: String { self ?? ""}
}


extension UIView {
    @IBInspectable
    var cornerRadiusT: CGFloat {
        get {
            self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
}

extension UIViewController {
    
    // 加载框 手动隐藏
    func showLoadHUD(title: String? = nil) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.label.text = title
    }
    
    func hideLoadHUD() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    // 加载框 自动隐藏
    func showTextHUD(title: String, subtitle: String? = nil) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = title
        hud.detailsLabel.text = subtitle
        hud.hide(animated: true, afterDelay: 2)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

extension UITextField {
    var unwrappedText: String { text ?? "" }
    var exactText: String {
        unwrappedText.isBlank ? "" : unwrappedText
    }
}

extension UITextView {
    var unwrappedText: String { text ?? "" }
    var exactText: String {
        unwrappedText.isBlank ? "" : unwrappedText
    }
}

extension UIImage {
    //指定构造器必须调用它直接父类的指定构造器方法
    //便利构造器必须调用同一类中定义的其他初始化方法
    //便利构造器在最后必须调用一个指定构造器
    convenience init?(data: Data?) {
        if let unwrappedData = data {
            self.init(data: unwrappedData)
        } else {
            return nil
        }
    }
    
    ///图片压缩处理值
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
        
    }
    func jpeg(jpegQuality: JPEGQuality) -> Data? {
        jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension Date {
    ///1:刚刚/5分钟前 2:今天21:10 3:昨天21:10 4:09-15 5:2019-09-15
    var formattedDate: String {
        let currentYear = Date().year
        if year == currentYear {
            if isToday {
                if minutesAgo > 10 {
                    return "今天 \(format(with: "HH:mm"))"
                } else {
                    return timeAgoSinceNow
                }
            } else if isYesterday {
                return "昨天 \(format(with: "HH:mm"))"
            } else {
                return format(with: "MM-dd")
            }
            
        } else if year < currentYear {
            return format(with: "yyyy-MM-dd")
        } else {
            return "未来"
        }
    }
}
