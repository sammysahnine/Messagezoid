//
//  ViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

public struct recentMessage {
    let date: String
    let content: String
}

public struct Chat {
    let id: String
    let otherName: String
    let otherUID: String
    let recentMessage: recentMessage
}

class ChatsViewController: UIViewController {
    
    private var chats = [Chat]()
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.cellid)
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
        
        //Creates label if no messages are shown
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
    
    private func messageFetcher(){
        let uid = (UserDefaults.standard.value(forKey: "userID") as? String) ?? "Test"
        DatabaseController.shared.fetchChats(for: uid, completion: { [weak self] result in
            switch result {
            case .success(let chats):
                guard self!.chats.isEmpty else {
                    return
                }
                
                self?.chats = chats
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(_):
                print("failed to get")
            }
        })
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
        let vc = ChatViewController(with: UID, chatID: nil)
        vc.title = username
        //Makes view controller title the username
        vc.navigationItem.largeTitleDisplayMode = .always
        //Makes the title large and left aligned
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
        messageFetcher()
        print(chats)
        print(chats.count)
        
        //Gets messages when view appears
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
        self.tableView.isHidden = false
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
        //Adds tables depending on about of chats the user is a part of
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatsTableViewCell.cellid,
                                                 for: indexPath) as! ChatsTableViewCell
        cell.configure(with: model)
        return cell
        //Sets up cells
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = chats[indexPath.row]
        print(model)
        //Gets information on user pressed to show relevant information on chatting screen
        let vc = ChatViewController(with: model.otherUID, chatID: model.id)
        vc.title = model.otherName
        navigationController?.pushViewController(vc, animated: true)
        //Navigates to ChatViewController when a cell is pressed, with the model of otherUID
        //This otherUID can be interpreted by the program to download and show the correct messages
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
        //Changes table cell height to 120
    }
}


//Chats VC: https://riptutorial.com/ios/example/6436/get-unix-epoch-time, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://stackoverflow.com/questions/43477489/swift-ios-firebase-not-returning-any-data?rq=1, https://www.youtube.com/watch?v=qsBDL7fT8Mg, https://www.youtube.com/watch?v=Pu7B7uEzP18, https://firebase.google.com/support/release-notes/ios, https://stackoverflow.com/questions/32665326/reference-to-property-in-closure-requires-explicit-self-to-make-capture-seman, https://stackoverflow.com/questions/26224693/how-can-i-make-the-memberwise-initialiser-public-by-default-for-structs-in-swi


