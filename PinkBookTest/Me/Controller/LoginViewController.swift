//
//  LoginViewController.swift
//  PinkBookTest
//
//  Created by mac on 2024/6/19.
//

import UIKit

class LoginViewController: UIViewController {
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("登陆", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.mainColor
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(localLogin), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginButton)
        setupUI()
        
    }
    
    
    
}

extension LoginViewController {
    
    func setupUI() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }
    
    //MARK: 一键登陆功能
    @objc func localLogin() {
        showLoadHUD()
        let config = JVAuthConfig()
        config.appKey = kJGAppKey
        config.authBlock = { _ in
            // 初始化
            if JVERIFICATIONService.isSetupClient() {
                //预取号（可验证当前运营商网络是否可以进行一键登录操作)
                JVERIFICATIONService.preLogin(5000) { (result) in
                    self.hideLoadHUD()
                    print("this: \(result)")
                    if let code = result["code"] as? Int, code == 7000 {
                        //当前设备可使用一键登录
                    }else{
                        print("当前设备不可使用一键登录")

                    }
                }
            }else{
                self.hideLoadHUD()
                print("初始化一键登录失败")

            }
        }
        
        JVERIFICATIONService.setup(with: config)
    }

    
}
