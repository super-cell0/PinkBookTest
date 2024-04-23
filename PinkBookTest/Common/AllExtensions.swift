//
//  AllExtensions.swift
//  PinkBookTest
//
//  Created by mac on 2024/4/9.
//

import Foundation

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
}
