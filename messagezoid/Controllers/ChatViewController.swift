//
//  ChatViewController.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 19/01/2022.
//

import UIKit
import MessageKit

//MessageKit: https://cocoapods.org/pods/MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType{
    var senderId: String
    var displayName: String
    var senderPFP: String
}

class ChatViewController: MessagesViewController {
    
    private var messageList = [Message]()
    private let testSender = Sender(senderId: "01", displayName: "Test", senderPFP: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messageList.append(Message(sender: testSender, messageId: "2", sentDate: Date(), kind: .text("the one thing i will always do in my life:")))
        messageList.append(Message(sender: testSender, messageId: "1", sentDate: Date(), kind: .text("subscribe to theroar176!!")))
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
    }
    
    
}


extension ChatViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate {
    func currentSender() -> SenderType {
        return testSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    
}

//User interface and MessageKit Code: https://messagekit.github.io, https://github.com/MessageKit/MessageKit/releases, https://stackoverflow.com/questions/51857751/how-to-properly-implement-messagekit-in-swift-4-delegate-functions-are-not-be, https://www.youtube.com/watch?v=1SqvDsz0ARo, https://www.youtube.com/watch?v=6v4fmg9iRSU, https://ibjects.medium.com/simple-text-chat-app-using-firebase-in-swift-5-b9fa91730b6c, https://www.scaledrone.com/blog/ios-chat-tutorial/


