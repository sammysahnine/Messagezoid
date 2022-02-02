//
//  ChatViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 19/01/2022.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseAuth

let newConversation = true

//MessageKit: https://cocoapods.org/pods/MessageKit

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType{
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    //public let newChat = false
    private var messageList = [Message]()

//    let testvarfalse = false
//    if testvarfalse == true {
//        let useridtest = UserDefaults.standard.value(forKey: "userID") as! String
//        let usernametest = UserDefaults.standard.value(forKey: "username") as! String
//        print(useridtest)
//        print(usernametest)
//    }

    
    private let deviceSender = Sender(senderId: UserDefaults.standard.value(forKey: "userID") as! String, displayName: "UserDefaults.standard.value(forKey: 'name')")
    
    public let otherUID: String
    
    init(with uid: String) {
        self.otherUID = uid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageList.append(Message(sender: deviceSender, messageId: "2", sentDate: Date(), kind: .text("the one thing i will always do in my life:")))
        messageList.append(Message(sender: deviceSender, messageId: "1", sentDate: Date(), kind: .text("subscribe to theroar176!!")))
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
    }
     
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        //Ensures that an empty message is not sent, reducing spam: https://stackoverflow.com/a/37533163
        if newConversation == true {
            
            let date = Date() // current date
            let unixtime = Int(date.timeIntervalSince1970)
            let unixtimestring = String(unixtime)
            //https://stackoverflow.com/a/40496261
            
            
            //Gets unix time: https://stackoverflow.com/a/25096863
            //Turn time to string: https://riptutorial.com/ios/example/6436/get-unix-epoch-time
            let userID = Auth.auth().currentUser!.uid
            let messageID = "\(userID)_\(otherUID)_at_\(unixtimestring)"
            print(messageID)
            
            let message = Message(sender: deviceSender, messageId: messageID, sentDate: Date(), kind: .text(text))
            print(message)
            
            DatabaseController.shared.startNewChat(with: otherUID, message: message, completion: { success in
                if success {
                    return
                }
                else {
                    print("error")
                }
            })
        }
        else {
            
        }
        
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return deviceSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    
}

//User interface and MessageKit Code: https://messagekit.github.io, https://github.com/MessageKit/MessageKit/releases, https://stackoverflow.com/questions/51857751/how-to-properly-implement-messagekit-in-swift-4-delegate-functions-are-not-be, https://www.youtube.com/watch?v=1SqvDsz0ARo, https://www.youtube.com/watch?v=6v4fmg9iRSU, https://ibjects.medium.com/simple-text-chat-app-using-firebase-in-swift-5-b9fa91730b6c, https://www.scaledrone.com/blog/ios-chat-tutorial/
