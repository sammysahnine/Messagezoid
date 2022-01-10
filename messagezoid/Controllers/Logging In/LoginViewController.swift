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
        
        view.backgroundColor = .white
        
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
                         action: #selector(LogInButtonAction),
                         for: .touchUpInside)
        
        self.view.addSubview(LogInButton)
        
        //Creating a button to with the title of "Log In": https://programmingwithswift.com/add-uibutton-programmatically-using-swidt/
    
    }
    
    @objc func LogInButtonAction() {
        let vc = UserLoginViewController()
        let nc = UINavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
    
        present(nc, animated: true)
    }
    
    
}
