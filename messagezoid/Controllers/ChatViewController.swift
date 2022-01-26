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

