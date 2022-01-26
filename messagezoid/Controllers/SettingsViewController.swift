//
//  ProfileViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettingsViewController: UIViewController {

    @IBOutlet var tableView: UITableView?
    
   let data = ["Log Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableHeaderView = createHeader()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView?.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.tableHeaderView = createHeader()
    }
    
    func createHeader () -> UIView? {
        let userID = UserDefaults.standard.value(forKey: "userID") as! String
        let pfpfilename = userID + "_profilepic.png"
        //Lets variable 'pfpfilename' equal the user's profile picture filename in the storage server
        let pfpdirectory = "ProfilePic/" + pfpfilename
        //Lets variable 'pfpdirectory' equal the user's profile picture's path in the storage server
        
        let headerview = UIView(frame:CGRect(x: 0, y: 0, width: self.view.width, height: 300))
        let imageView = UIImageView(frame: CGRect(x: (view.width-120)/2, y: 90, width: 120, height: 120))
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.systemFill.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.addSubview(imageView)
        return headerview
        
    }
}


extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textColor = .red
        cell.textLabel?.textAlignment = .center
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let confirmalert = UIAlertController(title: "Confirm", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        confirmalert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { [weak self] _ in
            
            guard let strong = self else {
                return
            }
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let vc = LoginViewController()
                let nc = UINavigationController(rootViewController: vc)
                nc.modalPresentationStyle = .fullScreen
                // This stops the user from dismissing the log in screen.
                strong.present(nc, animated: true)
            }
            catch {
                print("test")
            }
        }))
        
        confirmalert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(confirmalert, animated: true)
        
    }
}
