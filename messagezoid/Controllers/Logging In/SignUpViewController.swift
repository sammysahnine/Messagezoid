//
//  SignUpViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateEmail.delegate = self
        CreatePassword.delegate = self
        CreateUsername.delegate = self
        //Hides keyboard when return is pressed: https://stackoverflow.com/a/57217342
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //Makes back button white: https://stackoverflow.com/questions/46419286/how-to-change-the-back-button-color-in-a-detailviewcontroller
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Register"
        
        //Changes view controller title
        
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
        LoginContainer.addSubview(pfpimage)
        LoginContainer.addSubview(CreateEmail)
        LoginContainer.addSubview(CreatePassword)
        LoginContainer.addSubview(SignupButton)
        LoginContainer.addSubview(PFPButton)
        LoginContainer.addSubview(CreateUsername)
        SignupButton.addTarget(self, action: #selector(LoginValidate), for: .touchUpInside)
        PFPButton.addTarget(self, action: #selector(ChangePFP), for: .touchUpInside)
        
        //Adds all elements to the subview
        //A subview is used to help formatting on different device screen sizes
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
        //Centers the title of the view controller
    }
    
    //To center my titles: https://stackoverflow.com/questions/57245055/how-to-center-a-large-title-in-navigation-bar-in-the-middle/66366871
    
    private let pfpimage: UIImageView = {
        let pfpimage = UIImageView()
        pfpimage.image = UIImage(named: "blankpfp")
        pfpimage.contentMode = .scaleAspectFit
        pfpimage.clipsToBounds = true
        pfpimage.layer.masksToBounds = true
        pfpimage.layer.cornerRadius = pfpimage.frame.size.width/2
        return pfpimage
    }()
    
    // Creates a UIImage of the logo image, makes it scale to fit the device
    
    private let CreateEmail: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.backgroundColor = .white
        field.autocorrectionType = .no
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
        field.backgroundColor = .white
        field.autocorrectionType = .no
        field.returnKeyType = .default
        field.isSecureTextEntry = true
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
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
    
    private let CreateUsername: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.backgroundColor = .white
        field.autocorrectionType = .no
        field.returnKeyType = .default
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 3
        field.layer.borderColor = UIColor.darkGray.cgColor
        field.attributedPlaceholder = NSAttributedString(string: "Display Name...",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        field.textColor = UIColor.black
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
        pfpimage.frame = CGRect(x: (LoginContainer.width-size)/2, y: 20, width: size, height: size)
        CreateEmail.frame = CGRect(x: 30, y: pfpimage.bottom + 35, width: LoginContainer.width - 60, height: 42)
        CreatePassword.frame = CGRect(x: 30, y: CreateEmail.bottom + 15, width: LoginContainer.width - 60, height: 42)
        CreateUsername.frame = CGRect(x: 30, y: CreatePassword.bottom + 15, width: LoginContainer.width - 60, height: 42)
        PFPButton.frame = CGRect(x: 45, y: CreateUsername.bottom + 15, width: LoginContainer.width - 90, height: 42)
        SignupButton.frame = CGRect(x: 45, y: PFPButton.bottom + 15, width: LoginContainer.width - 90, height: 42)
        
        //This code will ensure the image is centred along the x axis: https://stackoverflow.com/questions/28173205/how-to-center-an-element-swift
        //This ensures all the elements are laid out in the desired manner
    }
    
    @objc private func LoginValidate() {
        CreateUsername.resignFirstResponder()
        CreateEmail.resignFirstResponder()
        CreatePassword.resignFirstResponder()
        
        //Removes focus from all textboxes
        
        guard let CheckEmail = CreateEmail.text, let CheckPassword = CreatePassword.text, let CheckUsername = CreateUsername.text, !CheckEmail.isEmpty, !CheckPassword.isEmpty, !CheckUsername.isEmpty else {
            LoginErrorLocal()
            return
        }
        //This code ensures that there is text in all the textboxes: https://stackoverflow.com/questions/24102641/how-to-check-if-a-text-field-is-empty-or-not-in-swift
        
        
        guard CheckEmail != "j.allen@parmiters.herts.sch.uk" else {
            LoginAllenError()
            return
        }
        
        //Checks if a particuar email address signs up to the app
        
        if case isValidPassword(CheckPassword) = false {
            PasswordErrorLocal()
            return
        }
                
        //Checking password complexity, returns error if password fails to meet requirements
        
        FirebaseAuth.Auth.auth().createUser(withEmail: CheckEmail, password: CheckPassword, completion: { [weak self] LoginResult, error in
    
            guard let strong = self else {
                return
            }
            
            guard error == nil else {
                self?.LoginErrorLocal()
                return
                //Displays error if there is an error when creating an account (that hasn't already been caught and dealt with)
            }
            
            guard let userID = Auth.auth().currentUser?.uid else {
                return
                //Gets the user ID from server, returns if error
            }
            
            UserDefaults.standard.set(userID, forKey: "userID")
            UserDefaults.standard.set(CheckEmail, forKey: "emailaddress")
            UserDefaults.standard.set(CheckUsername, forKey: "name")
            //Saves UID, Email and Name to cache
            
            let completionUser = NewUser(email: CheckEmail, username: CheckUsername, userID: userID)
            DatabaseController.shared.UserBuilder(with: completionUser, completion: { success in
                if success {
                    let imageToUpload = strong.pfpimage.image
                    guard let data = imageToUpload?.pngData() else {
                        return
                    }
                    //Gets data of image to prepare upload
                    
                    let name = completionUser.profilePicName
                    StorageManager.shared.uploadpfp(with: data, name: name, completion: { result in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_pic_url")
                            //Uploads profile picture to the database
                        case .failure(let error):
                            print(error)
                            //Catches error and prevents crash
                        }
                    })
                }
            })
            strong.navigationController?.dismiss(animated: true, completion: nil )
        })
    
    }
    
    private var authUser : User? {
        return Auth.auth().currentUser
        //Returns current user
    }

///    public func sendVerificationMail() {
///        if self.authUser != nil && !self.authUser!.isEmailVerified {
///            self.authUser!.sendEmailVerification(completion: { (error) in
///                let popup = UIAlertController(title: "Something's not right!", message: "Verification email couldn't be sent. Please try again", preferredStyle: .alert)
///                popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
///                self.present(popup, animated: true)
///            })
///       }
///        else {
///           // Either the user is not available, or the user is already verified.
///        }
///    }
    
///    //User Verification Email: https://stackoverflow.com/questions/49134297/send-an-email-verfication-email-to-a-new-firebase-user-in-swift

    
    func LoginErrorLocal() {
        let popup = UIAlertController(title: "Something's not right!", message: "Check your registration details and their formatting again! Maybe you meant to log in instead?", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        present(popup, animated: true)
        
        //Popup alert code for emty text fields: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        
        
    }
    
    func LoginAllenError() {
        let popup = UIAlertController(title: "FATAL ERROR!", message: "Brentford are a dreadful team. Please stop supporting them before using Messagezoid. Thank you!", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        present(popup, animated: true)
        
        //Popup alert code for emty text fields: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        //Informs user about what error has occured (easter egg)
        
        
    }
    
    func PasswordErrorLocal() {
        let popup = UIAlertController(title: "Something's not right!", message: "Ensure your password has one capital letter, one lowercase letter, one number, and is at least 8 characters!", preferredStyle: .alert)
        popup.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        present(popup, animated: true)
        
        //Popup alert code for emty text fields: https://stackoverflow.com/questions/24022479/how-would-i-create-a-uialertview-in-swift
        //Informs user about what error has occured (password complexity)
        
        
    }
    
    func isValidPassword(_ password : String) -> Bool {
        // least one uppercase,
        // least one digit
        // least one lowercase
        //  min 8 characters total
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@","^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$")
        //Checks password with the appropriate RegEx
        return passwordCheck.evaluate(with: password)
    }
    
    
    //Checking password complexity: https://sarunw.com/posts/different-ways-to-check-if-string-contains-another-string-in-swift/#check-if-a-string-contains-special-characters
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
        
        self.pfpimage.image = NewProfilePicture
        //Changes default profile picture at top of screen
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        
        //Handles if image selection is cancelled
    }
}

//User profile picture selection: https://stackoverflow.com/questions/25510081/how-to-allow-user-to-pick-the-image-with-swift

//Image Editing and Extention: https://stackoverflow.com/questions/26502931/how-to-get-the-edited-image-from-uiimagepickercontroller-in-swift



