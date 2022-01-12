//
//  SignUpViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit

class SignUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Register"
        view.addSubview(LoginContainer)
        LoginContainer.addSubview(blankspace)
        LoginContainer.addSubview(CreateEmail)
        ///CreateEmail.delegate = self
        LoginContainer.addSubview(CreatePassword)
        ///CreatePassword.delegate = self
        LoginContainer.addSubview(SignupButton)
        LoginContainer.addSubview(PFPButton)
        LoginContainer.addSubview(CreateUsername)
        ///CreateUsername.delegate = self
        SignupButton.addTarget(self, action: #selector(LoginValidate), for: .touchUpInside)
        PFPButton.addTarget(self, action: #selector(ChangePFP), for: .touchUpInside)
    }
    
    @objc private func ChangePFP(){
        self.showPhotoChooser()
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
        blankspace.image = UIImage(named: "blankpfp")
        blankspace.contentMode = .scaleAspectFit
        blankspace.layer.masksToBounds = true
        blankspace.layer.cornerRadius = 65
        return blankspace
    }()
    
    // Creates a UIImage of the logo image, makes it scale to fit the device
    
    private let CreateEmail: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.backgroundColor = .darkGray
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
        field.backgroundColor = .darkGray
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
    
    private let CreateUsername: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.backgroundColor = .darkGray
        field.autocorrectionType = .no
        field.returnKeyType = .default
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.placeholder = "Display Name..."
        
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        //Ensures there is a suitable gap between the textbox border and the text
        
        return field
        
        //Creates a text field for inputting an email address
        
    }()
    
    private let PFPButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose Profile Picture", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemIndigo
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //Creates profile picture button and it's properties
    
    private let SignupButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.backgroundColor = .systemGreen
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 20
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    //Creates signup button and it's properties
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        LoginContainer.frame = view.bounds
        let size = LoginContainer.width/3
        blankspace.frame = CGRect(x: (LoginContainer.width-size)/2, y: 20, width: size, height: size)
        CreateEmail.frame = CGRect(x: 30, y: blankspace.bottom + 35, width: LoginContainer.width - 60, height: 42)
        CreatePassword.frame = CGRect(x: 30, y: CreateEmail.bottom + 15, width: LoginContainer.width - 60, height: 42)
        CreateUsername.frame = CGRect(x: 30, y: CreatePassword.bottom + 15, width: LoginContainer.width - 60, height: 42)
        PFPButton.frame = CGRect(x: 45, y: CreateUsername.bottom + 15, width: LoginContainer.width - 90, height: 42)
        SignupButton.frame = CGRect(x: 45, y: PFPButton.bottom + 15, width: LoginContainer.width - 90, height: 42)
        
        //This code will ensure the image is centred along the x axis: https://stackoverflow.com/questions/28173205/how-to-center-an-element-swift
    }
    
    @objc private func LoginValidate() {
        CreateUsername.resignFirstResponder()
        CreateEmail.resignFirstResponder()
        CreatePassword.resignFirstResponder()
        guard let CheckEmail = CreateEmail.text, let CheckPassword = CreatePassword.text, let CheckUsername = CreateUsername.text, !CheckEmail.isEmpty, !CheckPassword.isEmpty, !CheckUsername.isEmpty else {
            LoginErrorLocal()
            return
        }
        //This code ensuures that there is text in all the textboxes: https://stackoverflow.com/questions/24102641/how-to-check-if-a-text-field-is-empty-or-not-in-swift
    }
    
    func LoginErrorLocal() {
        let popup = UIAlertController(title: "Something's not right!", message: "Some of your registration details seem to missing!", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        present(popup, animated: true)
        
        //Popup alert code for emty text fields: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        
    }
    
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showPhotoChooser(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        //Brings up UIImagePickerController
        
        vc.allowsEditing = true
        present(vc, animated: true)
        //Allows the photo to be cropped
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let NewProfilePicture = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.blankspace.image = NewProfilePicture
        //Changes default profile picture at top of screen
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        //Handles if image selection is cancelled
    }
}

//User profile picture selection: https://stackoverflow.com/questions/25510081/how-to-allow-user-to-pick-the-image-with-swift

//Image Editing and Extention: https://stackoverflow.com/questions/26502931/how-to-get-the-edited-image-from-uiimagepickercontroller-in-swift


