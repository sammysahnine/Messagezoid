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
import SDWebImage

//MessageKit: https://cocoapods.org/pods/MessageKit

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}
//Structure for all messages

struct Sender: SenderType {
    public var pfpURL: String
    public var senderId: String
    public var displayName: String
    //Variable initialisation
}
//Structure for all sender information

class ChatViewController: MessagesViewController {
    private var chats = [Message]()
    private let deviceSender = Sender(pfpURL: "", senderId: UserDefaults.standard.value(forKey: "userID") as! String, displayName: "You")
    //Sets deviceSender as the userID of the user
    public let otherUID: String
    public var chatID: String?
    public var newChat = false
    private var senderPFP: URL?
    private var otherPFP: URL?
    //Variable initialisation
    
    init(with uid: String, chatID: String?) {
        self.otherUID = uid
        self.chatID = chatID
        //Sets variables for specific chat
        super.init(nibName: nil, bundle: nil)
        print("chat id is \(String(describing: chatID))")
        //Debug print statement
        if let chatID = chatID {
            print("===FETCHING===")
            fetchMessages(chatID: chatID)
            //Debug print statement
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        //Required code
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
                    //Returns if there are no messages in the chat
                }
                print("message list: \(chats)")
                //Debug print statement
                DispatchQueue.main.async {
                    self?.chats = chats
                    self?.messagesCollectionView.reloadData()
                    self?.messagesCollectionView.scrollToItem(at: IndexPath(row: 0, section: (self?.chats.count)! - 1), at: .top, animated: false)
                    //Reload data and scroll to bottom: https://stackoverflow.com/a/58763424
                }
            case .failure(_):
                print("message get failure")
                //Debug print statement
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        //Sets up delegates
    }
}
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, !text.replacingOccurrences(of: "\n", with: "").isEmpty else {
            return
        }
        //Ensures that an empty message (just spaces or just new lines) is not sent, reducing spam: https://stackoverflow.com/a/37533163
        
        let date = Date() // current date
        let unixtime = Int(date.timeIntervalSince1970)
        let unixtimestring = String(unixtime)
        //https://stackoverflow.com/a/40496261
        
        
        //Gets unix time: https://stackoverflow.com/a/25096863
        //Turn time to string: https://riptutorial.com/ios/example/6436/get-unix-epoch-time
        let userID = Auth.auth().currentUser!.uid
        let messageID = "\(userID)_\(otherUID)_at_\(unixtimestring)"
        print(messageID)
        //Debug print statement
        
        let message = Message(sender: deviceSender, messageId: messageID, sentDate: Date(), kind: .text(text))
        print(message)
        //Debug print statement
        
        if chatID == nil {
        //Checks if a chat exists, if not then...
            DatabaseController.shared.startNewChat(with: self.otherUID, otherName: self.title!, message: message, completion: { success in
                if success == true {
                    print("NEW CHAT STARTED")
                    //(Debug print statement)
                    //... starts a new chat, else...
                    ///self?.newChat = false
                }
                else {
                    print("error when sending new message")
                    //(Debug print statement)
                }
            })
        }
        else {
        //... sends a messages to the existing chat.
            print("SENDING TO EXISTING CHAT")
            guard let chatID = self.chatID else { return }
            print(chatID)
            DatabaseController.shared.sendMessage(to: chatID, message: message, otherName: self.title!, otherUID: otherUID, completion: { success in
                if success {
                    print("message sent")
                    //(Debug print statement)
                }
                else {
                    print("MESSAGE SEND FAILURE")
                    //(Debug print statement)
                }
            })
        }
        
        inputBar.inputTextView.text = ""
        //Clears textbox after message sent: https://stackoverflow.com/a/67297610
        
        fetchMessages(chatID: chatID ?? "let_\(message.messageId)")
        //Fetches messages for existing chat, or recently made chat.
        //Forces UID creation if one does not already exist
    }
}

extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return deviceSender
        //Returns deviceSends (user's device)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chats[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chats.count
        //Makes cells for each messafe in chat
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        let sender = message.sender
        if sender.senderId == deviceSender.senderId {
            //If message is from user's device...
            if let profilePictureURL = self.senderPFP {
                avatarView.sd_setImage(with: profilePictureURL, completed: nil)
                //... and image is download it, set as image, else...
            }
            else {
                //(fetch url)
                let uid = UserDefaults.standard.value(forKey: "userID") as! String
                let path = "ProfilePic/images/\(uid)_profilepic.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPFP = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                        //... download the image, and then set it
                    case .failure(_):
                        print("PFP FETCH ERROR - USER")
                        //(Debug print statement in case of error)
                    }
                })
            }
        }
        else {
        //If message is from other user
            if let otherProfilePictureURL = self.otherPFP {
                avatarView.sd_setImage(with: otherProfilePictureURL, completed: nil)
                //... and image is download it, set as image, else...
            }
            else {
                //(fetch url)
                let uid = self.otherUID
                let path = "ProfilePic/images/\(uid)_profilepic.png"
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.otherPFP = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                            //... download the image, and then set it
                        }
                    case .failure(_):
                        print("PFP FETCH ERROR")
                        //(Debug print statement in case of error)
                    }
                })
            }
        }
    }
    
}

//User interface and MessageKit Code: https://messagekit.github.io, https://github.com/MessageKit/MessageKit/releases, https://stackoverflow.com/questions/51857751/how-to-properly-implement-messagekit-in-swift-4-delegate-functions-are-not-be, https://www.youtube.com/watch?v=1SqvDsz0ARo, https://www.youtube.com/watch?v=6v4fmg9iRSU, https://ibjects.medium.com/simple-text-chat-app-using-firebase-in-swift-5-b9fa91730b6c, https://www.scaledrone.com/blog/ios-chat-tutorial/, https://stackoverflow.com/questions/55052037/cast-from-string-to-unrelated-type-string-string-always-fails?rq=1, https://stackoverflow.com/questions/32665326/reference-to-property-in-closure-requires-explicit-self-to-make-capture-seman, https://stackoverflow.com/questions/26224693/how-can-i-make-the-memberwise-initialiser-public-by-default-for-structs-in-swi


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
