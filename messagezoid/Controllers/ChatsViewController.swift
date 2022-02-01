//
//  ViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
        
        //Table created with help from: https://softauthor.com/ios-uitableview-programmatically-in-swift/
    }()
    
    private let NoChats: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .lightGray
        label.font =  .systemFont(ofSize: 19, weight: .semibold )
        label.text = "Uh oh!\nNo conversations were found!"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(NoChats)
        view.addSubview(tableView)
        //Having the label behind the table means that if the table is not shown, the label will inform the user of the lack of chats.
        self.tableView.rowHeight = 75
        //Change row height: https://stackoverflow.com/a/31854722
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchNewChat))
    }
    
    @objc private func searchNewChat(){
        let vc = NewChatViewController()
        vc.completion = { [weak self] result in
            self?.startNewChat(result: result)
            //Starts new chat with the result of whichever user was pressed: https://www.youtube.com/watch?v=qsBDL7fT8Mg
        }
        let nc = UINavigationController(rootViewController: vc)
        present(nc, animated: true)
    }
    //Change VC to choose a user
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    //Sets table's frame
    
    private func startNewChat(result:[String:String]) {
        guard let UID = result["UID"] else {return}
        let username = result["username"]
        let vc = ChatViewController(with: UID)
        vc.title = username
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }
    //UID is stored to be referenced later, lets device know who to send messages to
    //Sets title as username that was clicked
    //Switches the view controller
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CheckLoginStatus()
        tableView.delegate = self
        tableView.dataSource = self
        getChats()
    }
    
    //Gets messages from server when needed.
    
    func CheckLoginStatus() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nc = UINavigationController(rootViewController: vc)
            nc.modalPresentationStyle = .fullScreen
            // This stops the user from dismissing the log in screen.
            present(nc, animated: false)
        }
        // If the user is not logged in, the Login View controller will be shown.
    }
    
    private func tableSetup() {
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    private func getChats(){
        tableView.isHidden = false
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Test Message"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController(with:"")
        vc.title = "User 1"
        vc.navigationItem.largeTitleDisplayMode = .always
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


