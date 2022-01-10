//
//  UserLoginViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit

class UserLoginViewController: UIViewController {
    
    private let LoginContainer: UIScrollView = {
        let LoginContainer = UIScrollView()
        LoginContainer.clipsToBounds = true
        return LoginContainer
        
    }()
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.centerTitle()
    }
    
    //To center my titles: https://stackoverflow.com/questions/57245055/how-to-center-a-large-title-in-navigation-bar-in-the-middle/66366871
    
    private let blankspace: UIImageView = {
        let blankspace = UIImageView()
        blankspace.image = UIImage(named: "logo")
        blankspace.contentMode = .scaleAspectFit
        return blankspace
        }()
        
        // Creates a UIImage of the logo image, makes it scale to fit the device
        
    private let CreateEmail: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        //Ensures there is a suitable gap between the textbox border and the text
        
        return field
        
        //Creates a text field for inputting an email address
    
    }()
    
    private let CreatePassword: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.isSecureTextEntry = true
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        //Ensures there is a suitable gap between the textbox border and the text
        
        return field
        
        //Creates a text field for inputting a password
        
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white   
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Log In to MessageZoid"
        
        view.addSubview(LoginContainer)
        LoginContainer.addSubview(blankspace)
        LoginContainer.addSubview(CreateEmail)
        LoginContainer.addSubview(CreatePassword)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LoginContainer.frame = view.bounds
        let size = LoginContainer.width/3
        blankspace.frame = CGRect(x: (LoginContainer.width-size)/2, y: 20, width: size, height: size)
        CreateEmail.frame = CGRect(x: 30, y: blankspace.bottom + 35, width: LoginContainer.width - 60, height: 42)
        CreatePassword.frame = CGRect(x: 30, y: CreateEmail.bottom + 15, width: LoginContainer.width - 60, height: 42)
        
        //This code will ensure the image is centred along the x axis: https://stackoverflow.com/questions/28173205/how-to-center-an-element-swift
    
        func backToSignup() {
            let vc = LoginViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    
    
    }
}



