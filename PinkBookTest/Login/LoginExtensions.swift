//
//  LoginExtensions.swift
//  PinkBookTest
//
//  Created by mac on 2024/8/9.
//

import Foundation


extension UIViewController {
    
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
                    //print("this: \(result)")
                    if let code = result["code"] as? Int, code == 7000 {
                        // 预取号成功
                        // 当前设备可使用一键登录
                        print("当前设备可使用一键登录")
                        self.setLocalLoginUI()
                        self.presentLocalLoginViewController()
                        
                    }else{
                        //print("预取号失败 错误码: \(String(describing: result["code"])), 错误描述: \(String(describing: result["content"]))")
                        print("当前设备不可使用一键登录")
                        self.presentLoginVC()
                    }
                }
            }else{
                self.hideLoadHUD()
                print("初始化一键登录失败")
                self.presentLoginVC()
                
            }
        }
        
        JVERIFICATIONService.setup(with: config)
    }
    
    /// 弹出登录页面
    func presentLocalLoginViewController() {
        JVERIFICATIONService.getAuthorizationWith(self, hide: true, animated: true, timeout: 5*1000, completion: { (result) in
            if let loginToken = result["loginToken"] as? String {
                // 一键登录成功
                JVERIFICATIONService.clearPreLoginCache()
                //print("loginToken: \(loginToken)")
                
                
            } else {
                print("一键登录失败")
                self.otherLogin()
            }
            
        }){ (type, content) in
            print("一键登录 actionBlock :type = \(type), content = \(content)")
        }
    }
    
    func setLocalLoginUI() {
        let config = JVUIConfig()
        config.prefersStatusBarHidden = true
        config.navTransparent = true
        //config.navReturnImg = UIImage(systemName: "chevron.backward.circle")!
        config.navText = NSAttributedString(string: "")
        config.navReturnHidden = true
        config.navControl = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(dismissLocalLoginVC))
        
        config.logoImg = UIImage(named: "cmccLogo")!
        let logoWidth = config.logoImg.size.width
        let logoHeight = logoWidth
        let logoConstraintW = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.none, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: logoWidth)
        let logoConstraintH = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.none, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: logoHeight)
        let logoConstraintX = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.super, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let logoConstraintY = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.super, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1/7, constant: 0)
        config.logoConstraints = [logoConstraintX!, logoConstraintY!, logoConstraintW!, logoConstraintH!]
        
        let numberConstraintY = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.super, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 35)
        config.numberConstraints = [logoConstraintX!, numberConstraintY!]
        
        let slogenConstraintsY = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.number, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 35)
        config.sloganConstraints = [logoConstraintX!, slogenConstraintsY!]
        
        config.logBtnText = "同意一键登录"
        config.logBtnImgs = [
            UIImage(named: "localLoginBtn-nor")!,
            UIImage(named: "localLoginBtn-nor")!,
            UIImage(named: "localLoginBtn-hig")!,
        ]
        let logBtnContraintsY = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.slogan, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 50)
        config.logBtnConstraints = [logoConstraintX!, logBtnContraintsY!]
        
        config.privacyState = true
        config.checkViewHidden = true
        config.privacyTextAlignment = .center
        config.agreementNavBackgroundColor = UIColor.mainColor
        config.agreementNavReturnImage = UIImage(systemName: "chevron.backward.circle")!
        config.appPrivacyOne = ["用户协议", "https://www.cctalk.com/m/group/86306378"]
        config.appPrivacyTwo = ["隐私政策", "https://www.cctalk.com/m/group/86308246"]
        config.privacyComponents = ["登录注册代表你已同意", "和", "", ""]
        config.appPrivacyColor = [UIColor.secondaryLabel, UIColor.mainColor]
        let privacyContraintsY = JVLayoutConstraint(attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, to: JVLayoutItem.super, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: -50)
        config.privacyConstraints = [logoConstraintX!, privacyContraintsY!]
 
        
        JVERIFICATIONService.customUI(with: config) { [self] customView in
            // 自定义view
            let button = UIButton()
            button.setTitle("其他登录方式", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(UIColor.secondaryLabel, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: #selector(self.otherLogin), for: .touchUpInside)
            
            customView.addSubview(button)
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: customView.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: customView.centerYAnchor, constant: 160),
                button.widthAnchor.constraint(equalToConstant: 279),
            ])
        }
    }
    
    @objc func otherLogin() {
        JVERIFICATIONService.dismissLoginController(animated: true) {
            self.presentLoginVC()
        }
    }
    
    @objc func dismissLocalLoginVC() {
        JVERIFICATIONService.dismissLoginController(animated: true) {}
    }
    
    func presentLoginVC() {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let loginNavigationController = mainStoryBoard.instantiateViewController(identifier: kLoginNavigtionControllerID)
        loginNavigationController.modalPresentationStyle = .fullScreen
        present(loginNavigationController, animated: true, completion: nil)
    }
    
}

