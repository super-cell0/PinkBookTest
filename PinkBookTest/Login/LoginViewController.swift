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
    
    func setupUI() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8).isActive = true
    }
    
}


