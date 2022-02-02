//
//  UserLoginViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit
import FirebaseAuth

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
        field.backgroundColor = .white
        field.returnKeyType = .default
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Email Address...",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        // Makes placeholder text visible: https://www.codegrepper.com/code-examples/swift/change+placeholder+text+color+in+swift
        
        field.textColor = UIColor.black
        
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
        field.backgroundColor = .white
        field.returnKeyType = .default
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.isSecureTextEntry = true
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Password...",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        field.textColor = UIColor.black
        
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
    
    //Creates login button
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //Makes back button white: https://stackoverflow.com/questions/46419286/how-to-change-the-back-button-color-in-a-detailviewcontroller
        
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .clear
        title = "Log In"
        
        let appearance = UINavigationBarAppearance()
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationItem.standardAppearance = appearance
        
        //Forces white title: https://stackoverflow.com/questions/43706103/how-to-change-navigationitem-title-color
        
        let gradient = CAGradientLayer()
         gradient.frame = self.view.bounds
         gradient.startPoint = CGPoint(x:0.0, y:0.5)
         gradient.endPoint = CGPoint(x:1.0, y:0.5)
         gradient.colors = [UIColor.systemTeal.cgColor, UIColor.systemPurple.cgColor]
         gradient.locations =  [-0.5, 1.5]

         let animation = CABasicAnimation(keyPath: "colors")
         animation.fromValue = [UIColor.systemPurple.cgColor, UIColor.systemTeal.cgColor]
        animation.toValue = [UIColor.systemTeal.cgColor, UIColor.systemPurple.cgColor]
         animation.duration = 5.0
         animation.autoreverses = true
         animation.repeatCount = Float.infinity

         gradient.add(animation, forKey: nil)
         self.view.layer.addSublayer(gradient)
        
        
        //Background animation: https://appcodelabs.com/make-your-ios-app-pop-animated-gradients
        
        view.addSubview(LoginContainer)
        LoginContainer.addSubview(blankspace)
        LoginContainer.addSubview(CreateEmail)
        ///CreateEmail.delegate = self
        LoginContainer.addSubview(CreatePassword)
        ///CreatePassword.delegate = self
        LoginContainer.addSubview(LoginButton)
        LoginButton.addTarget(self, action: #selector(LoginValidate), for: .touchUpInside)
    }
    
    
    //Adds elements to Container
    
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
        CreateEmail.resignFirstResponder()
        CreatePassword.resignFirstResponder()
        
        
        guard let CheckEmail = CreateEmail.text, let CheckPassword = CreatePassword.text,
              !CheckEmail.isEmpty, !CheckPassword.isEmpty else {
                  LoginErrorLocal()
                  return
              }
    
        FirebaseAuth.Auth.auth().signIn(withEmail: CheckEmail, password: CheckPassword, completion: { [weak self] LoginResult, error in
            guard let strong = self else {
                return
            }
            
            guard error == nil else {
                self?.LoginErrorLocal()
                return
            }
            
            //Returns error message is an error occures
            
            let userID = Auth.auth().currentUser?.uid
            UserDefaults.standard.set(userID, forKey: "userID")
            UserDefaults.standard.set(CheckEmail, forKey: "emailaddress")
            let displayname = //Username
            ///UserDefaults.standard.set(displayname, forKey: "name")
            //Saves email and UID to cache
            strong.navigationController?.dismiss(animated: true, completion: nil )
            //Else, logs user in
        })
    
    }
    
    //Checks that username + password field have text entered
    
    func LoginErrorLocal() {
        let popup = UIAlertController(title: "Something's not right!", message: "Try checking your username and email again!", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        present(popup, animated: true)
        
        //Creates pop up if text is not entered
        //Popup alert code for emty text fields: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        
    }
}
