//
//  LoginViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit

class LoginViewController: UIViewController {
    
   override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.centerTitle()
    
   }
    //To center my titles: https://stackoverflow.com/questions/57245055/how-to-center-a-large-title-in-navigation-bar-in-the-middle/66366871

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Welcome!"
        
        //Create a large, modern title at the top of the screen
        
        let LogInButton = UIButton(frame: CGRect(x: 100,
                                            y: 300,
                                            width: 200,
                                            height: 60))
        LogInButton.setTitle("Log In",
                        for: .normal)
        
        LogInButton.setTitleColor(.purple,
                             for: .normal)
        
        LogInButton.addTarget(self,
                         action: #selector(LoginButtonAction),
                         for: .touchUpInside)
        
        self.view.addSubview(LogInButton)
        
        
        let SignUpButton = UIButton(frame: CGRect(x: 100,
                                            y: 500,
                                            width: 200,
                                            height: 60))
        SignUpButton.setTitle("Sign Up",
                        for: .normal)
        
        SignUpButton.setTitleColor(.purple,
                             for: .normal)
        
        SignUpButton.addTarget(self,
                         action: #selector(SignUpButtonAction),
                         for: .touchUpInside)
        
        self.view.addSubview(SignUpButton)
        
        //Creating a button to with the title of "Log In": https://programmingwithswift.com/add-uibutton-programmatically-using-swidt/
    
    }
    
    @objc private func LoginButtonAction() {
        let vc = UserLoginViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func SignUpButtonAction() {
        let vc = SignUpViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
