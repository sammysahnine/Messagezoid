//
//  ViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 07/01/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

public struct recentMessage {
    let date: String
    let content: String
    //Sets up structure for how recent message data will be formatted
}

public struct Chat {
    let id: String
    let otherName: String
    let otherUID: String
    let recentMessage: recentMessage
    //Sets up structure for how a chat will be formatted
}

class ChatsViewController: UIViewController {
    
    private var chats = [Chat]()
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(ChatsTableViewCell.self, forCellReuseIdentifier: ChatsTableViewCell.cellid)
        return table
        
        //Table created with help from: https://softauthor.com/ios-uitableview-programmatically-in-swift/
    }()
    
    func greetingLogic() -> String {
      let hour = Calendar.current.component(.hour, from: Date())
      
      let NEW_DAY = 0
      let NOON = 12
      let SUNSET = 18
      let MIDNIGHT = 24
      
      var greetingText = "Hello" // Default greeting text
      switch hour {
      case NEW_DAY..<NOON:
          greetingText = "Good Morning,"
          //Shows appropriate time greeting
      case NOON..<SUNSET:
          greetingText = "Good Afternoon,"
          //Shows appropriate time greeting
      case SUNSET..<MIDNIGHT:
          greetingText = "Good Evening,"
          //Shows appropriate time greeting
      default:
          _ = "Hello"
          //Shows default time greeting
      }
      
      return greetingText
    }
    
    //Time based greeting text: https://freakycoder.com/ios-notes-51-how-to-set-a-time-based-dynamic-greeting-message-swift-5-6c629632ceb5
    //For changing the title depending on the time of day to greet the user
    
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
///        let greeting = greetingLogic()
///        guard let username = UserDefaults.standard.value(forKey: "name") else {
///            return
///        }
///        title = "\(greeting) \(username)"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(searchNewChat))
        //Adds button to search for a new user to chat to
    }
    
    private func messageFetcher() {
        guard let uid = UserDefaults.standard.value(forKey: "userID") as? String else {
            return
        }
        //Gets uid and saves as a variable
        DatabaseController.shared.fetchChats(for: uid, completion: { [weak self] result in
            switch result {
            case .success(let chats):
                guard !chats.isEmpty else {
                    return
                    //Returns code if chat is empty
                }
                self?.chats = chats
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    //Refreshes table to show new messages
                }
            case .failure(_):
                print("failed to get")
                //Debug print statement
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
        //Ensures that the table of chats is shown
    }
}

extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("CHATS AMOUNT \(chats.count)")
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


