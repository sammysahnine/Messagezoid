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
import AudioToolbox

//MessageKit: https://cocoapods.org/pods/MessageKit

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
    public var pfpURL: String
    public var senderId: String
    public var displayName: String
}

class ChatViewController: MessagesViewController {
    private var chats = [Message]()
    
    private let deviceSender = Sender(pfpURL: "", senderId: UserDefaults.standard.value(forKey: "userID") as! String, displayName: "You")
    
    public let otherUID: String
    public let chatID: String?
    public var newChat = false
    
    init(with uid: String, chatID: String?) {
        self.otherUID = uid
        self.chatID = chatID
        super.init(nibName: nil, bundle: nil)
        print("chat id is \(String(describing: chatID))")
        if let chatID = chatID {
            print("===FETCHING===")
            fetchMessages(chatID: chatID)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func fetchMessages(chatID: String) {
        print("chat id is \(String(describing: chatID)) (during fetch)")
        DatabaseController.shared.fetchChatsInChat(with: chatID, completion: { [weak self] result in
            switch result {
            case .success(let chats):
                guard chats.isEmpty == false else {
                    return
                }
                
                print("message list: \(chats)")
                
                DispatchQueue.main.async {
                    self?.chats = chats
                    self?.messagesCollectionView.reloadData()
                }
                
            case .failure(_):
                print("message get failure")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        print("before if \(newChat)")
        
        
///        if newChat == true {
///            print("SENDING TO NEW")
///            DatabaseController.shared.startNewChat(with: otherUID, otherName:self.title!, message: message, completion: { [weak self] success in
///                print(\(success)")
///                if success == true {
///                    print("NEW CHAT STARTED")
///                    self?.newChat = false
///                }
///                else {
///                    print("error when sending new message")
///                }
///            })
///        }
///
///
///        else {
///            print("SENDING TO EXISTING CHAT")
///            guard let chatID = chatID else { return }
///            print(chatID)
///            DatabaseController.shared.sendMessage(to: chatID, message: message, otherName: self.title!, completion: { success in
///                if success {
///                    print("message sent")
///                }
///                else {
///                    print("MESSAGE SEND FAILURE")
///                }
///            })
///        }
   
        
            if chatID == nil {
                DatabaseController.shared.startNewChat(with: self.otherUID, otherName: self.title!, message: message, completion: { [weak self] success in
                    if success == true {
                        print("NEW CHAT STARTED")
                        self?.newChat = false
                    }
                    else {
                        print("error when sending new message")
                    }
                })
            }
            else {
                print("SENDING TO EXISTING CHAT")
                guard let chatID = self.chatID else { return }
                print(chatID)
                DatabaseController.shared.sendMessage(to: chatID, message: message, otherName: self.title!, completion: { success in
                    if success {
                        print("message sent")
                    }
                    else {
                        print("MESSAGE SEND FAILURE")
                    }
                })
            }
        }
    
    }


extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return deviceSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chats[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chats.count
    }
    
    
}

//User interface and MessageKit Code: https://messagekit.github.io, https://github.com/MessageKit/MessageKit/releases, https://stackoverflow.com/questions/51857751/how-to-properly-implement-messagekit-in-swift-4-delegate-functions-are-not-be, https://www.youtube.com/watch?v=1SqvDsz0ARo, https://www.youtube.com/watch?v=6v4fmg9iRSU, https://ibjects.medium.com/simple-text-chat-app-using-firebase-in-swift-5-b9fa91730b6c, https://www.scaledrone.com/blog/ios-chat-tutorial/, https://stackoverflow.com/questions/55052037/cast-from-string-to-unrelated-type-string-string-always-fails?rq=1, https://stackoverflow.com/questions/32665326/reference-to-property-in-closure-requires-explicit-self-to-make-capture-seman, https://stackoverflow.com/questions/26224693/how-can-i-make-the-memberwise-initialiser-public-by-default-for-structs-in-swi
