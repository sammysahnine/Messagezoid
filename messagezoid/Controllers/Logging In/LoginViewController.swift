//
//  LoginViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .clear
        title = "Welcome!"
        
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
         animation.fromValue = [UIColor.systemTeal.cgColor, UIColor.systemPurple.cgColor]
        animation.toValue = [UIColor.systemPurple.cgColor, UIColor.systemTeal.cgColor]
         animation.duration = 5.0
         animation.autoreverses = true
         animation.repeatCount = Float.infinity

         gradient.add(animation, forKey: nil)
         self.view.layer.addSublayer(gradient)
        
        
        //Background animation: https://appcodelabs.com/make-your-ios-app-pop-animated-gradients
        
        
        view.addSubview(LoginContainer)
        LoginContainer.addSubview(blankspace)
        LoginContainer.addSubview(SignupButton)
        LoginContainer.addSubview(LoginButton)
        ///LoginContainer.addSubview(GoogleButton)
        SignupButton.addTarget(self, action: #selector(SignUpButtonAction), for: .touchUpInside)
        LoginButton.addTarget(self, action: #selector(LoginButtonAction), for: .touchUpInside)
    }
    
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
        blankspace.image = UIImage(named: "blank")
        blankspace.contentMode = .scaleAspectFit
        blankspace.layer.masksToBounds = true
        return blankspace
    }()
    
    // Creates a UIImage of the logo image, makes it scale to fit the device
    
    
    private let LoginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
        button.backgroundColor = MessagezoidBlue
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //Creates login button and it's properties
    
    private let SignupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .bold)
        button.backgroundColor = .systemGreen
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //Creates signup button and it's properties
    
    ///private let GoogleButton = GIDSignInButton()
    
    //Creates signup button and it's properties
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LoginContainer.frame = view.bounds
        let size = LoginContainer.width/3
        blankspace.frame = CGRect(x: (LoginContainer.width-size)/2, y: 20, width: size, height: size)
        LoginButton.frame = CGRect(x: 45, y: blankspace.bottom + 40, width: LoginContainer.width - 90, height: 52)
        SignupButton.frame = CGRect(x: 45, y: LoginButton.bottom + 40, width: LoginContainer.width - 90, height: 52)
        ///GoogleButton.frame = CGRect(x: 45, y: SignupButton.bottom + 40, width: LoginContainer.width - 90, height: 52)
        
        //This code will ensure the image is centred along the x axis: https://stackoverflow.com/questions/28173205/how-to-center-an-element-swift
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


//private let GoogleButton: UIButton = {
//    let button = UIButton()
//    button.setTitle("Continue with Google", for: .normal)
//    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
//    button.backgroundColor = .white
//    button.setTitleColor(.black, for: .normal)
//    button.layer.masksToBounds = true
//    button.layer.cornerRadius = 20
//    return button
//}()
