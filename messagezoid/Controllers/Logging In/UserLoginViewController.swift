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
        field.returnKeyType = .default
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.layer.borderColor = UIColor.darkGray.cgColor
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
        field.returnKeyType = .default
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.isSecureTextEntry = true
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.placeholder = "Password..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        //Ensures there is a suitable gap between the textbox border and the text
        
        return field
        
        //Creates a text field for inputting a password
        
    }()
    
    private let LoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = MessagezoidBlue
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
        
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
        LoginContainer.addSubview(LoginButton)
        LoginButton.addTarget(self, action: #selector(LoginValidate), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LoginContainer.frame = view.bounds
        let size = LoginContainer.width/3
        blankspace.frame = CGRect(x: (LoginContainer.width-size)/2, y: 20, width: size, height: size)
        CreateEmail.frame = CGRect(x: 30, y: blankspace.bottom + 35, width: LoginContainer.width - 60, height: 42)
        CreatePassword.frame = CGRect(x: 30, y: CreateEmail.bottom + 15, width: LoginContainer.width - 60, height: 42)
        LoginButton.frame = CGRect(x: 45, y: CreatePassword.bottom + 15, width: LoginContainer.width - 90, height: 42)
        
        //This code will ensure the image is centred along the x axis: https://stackoverflow.com/questions/28173205/how-to-center-an-element-swift
    }
    
    @objc private func LoginValidate() {
        guard let CheckEmail = CreateEmail.text, let CheckPassword = CreatePassword.text,
              !CheckEmail.isEmpty, !CheckPassword.isEmpty else {
                  LoginErrorLocal()
                  return
              }
    }
    
    func LoginErrorLocal() {
        let popup = UIAlertController(title: "Something's not right!", message: "Either your email or password field seems to be empty! Maybe try checking that and then try again!", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        present(popup, animated: true)
        
        //Popup alert code for emty text fields: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        
    }
}
