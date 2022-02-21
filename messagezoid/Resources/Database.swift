//
//  Database.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 15/01/2022.
//

import Foundation
import FirebaseDatabase
import Firebase
import FirebaseAuth

final class DatabaseController {
    static let shared = DatabaseController()
    private let databaseadd = Database.database().reference()
}

extension DatabaseController {
    public func UserBuilder(with user: NewUser, completion: @escaping (Bool) -> Void) {
        databaseadd.child(user.userID).setValue(["username": user.username, "email": user.email], withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
                //if error, return
            }
            
            self.databaseadd.child("UserList").observeSingleEvent(of: .value, with: { snapshot in
                if var UIDList = snapshot.value as? [[String: String]] {
                    
                    let newUID = ["username": user.username, "UID": user.userID]
                    //get username and UID
                    
                    UIDList.append(newUID)
                    //add it to the list of users
                    
                    
                    
                    self.databaseadd.child("UserList").setValue(UIDList, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                else {
                    let UIDList: [[String: String]] = [
                        ["username": user.username, "UID": user.userID]
                    ]
                    self.databaseadd.child("UserList").setValue(UIDList, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
        })
    }
    
    //Creating user list: https://firebase.google.com/docs/auth/admin/manage-users, https://www.youtube.com/watch?v=qD582zfXlgo, https://www.youtube.com/watch?v=Hmr8PsG9E2w
    
    public func requestUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        databaseadd.child("UserList").observeSingleEvent(of: .value, with: { snapshot in
            guard let value  = snapshot.value as? [[String: String]] else {
                completion(.failure(FetchError.couldNotRequest))
                return
            }
            
            completion(.success(value))
        })
    }
    
    public enum FetchError: Error {
        case couldNotRequest
    }
    
}

//This allows the searching of users: https://firebase.googleblog.com/2014/04/best-practices-arrays-in-firebase.html, https://www.youtube.com/watch?v=Hmr8PsG9E2w, https://firebase.google.com/docs/firestore/manage-data/data-types

extension DatabaseController {
    
    public func startNewChat(with otherUID: String, otherName: String, message: Message, completion: @escaping(Bool) -> Void) {
        let uid = (Auth.auth().currentUser?.uid)!
        let refer = databaseadd.child("\(uid)")
        //get uid and make directory path
        refer.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            var userFolder = snapshot.value as? [String: Any]
            
            var messagestring = ""
            
            switch message.kind {
            case .text(let messageText):
                messagestring = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            //extracting raw string data from the message
            
            let date = Date() // current date
            let unixtime = Int(date.timeIntervalSince1970)
            let unixtimestring = String(unixtime)
            //https://stackoverflow.com/a/40496261
            
            let chatID = "let_\(message.messageId)"
            
            //setting up
            
            
            let newChatData = ["chatID": chatID, "otherUID": otherUID, "otherName": otherName, "latestMessage": ["messageContent": messagestring, "date": unixtimestring]] as [String : Any]
            
            let name = UserDefaults.standard.value(forKey: "name") as! String
            let otherNewChatData = ["chatID": chatID, "otherUID": uid, "otherName": name, "latestMessage": ["messageContent": messagestring, "date": unixtimestring]] as [String : Any]
            
            self?.databaseadd.child("\(otherUID)/chats").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var otherChats = snapshot.value as? [[String:Any]] {
                    otherChats.append(otherNewChatData)
                    self?.databaseadd.child("\(otherUID)/chats").setValue(otherChats)
                }
                else {
                    self?.databaseadd.child("\(otherUID)/chats").setValue([otherNewChatData])
                }
            })
            
            if var chats = userFolder!["chats"] as? [[String: Any]] {
                //conversation exists
                
                chats.append(newChatData)
                userFolder!["chats"] = chats
                refer.setValue(userFolder, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                self?.createChatFolder(chatID: chatID, otherName: otherName, message: message)
                //Add data to the chat
                })
            }
            
            else {
                //doesnt exist
                userFolder!["chats"] = [newChatData]
                refer.setValue(userFolder, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                self?.createChatFolder(chatID: chatID, otherName: otherName, message: message)
                
                //make directory and add it to the chat
                    
                })
            }
        })
    }
    
    private func createChatFolder(chatID: String, otherName: String, message: Message) {
        
        var messagestring = ""
        
        switch message.kind {
        case .text(let messageText):
            messagestring = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        //extracting raw string data from the message
        
        let date = message.sentDate
        let unixtime = Int(date.timeIntervalSince1970)
        let unixtimestring = String(unixtime)
        //https://stackoverflow.com/a/40496261
        
        //setup
        
        let uid = Auth.auth().currentUser!.uid as String
        
        //get UID
        
        let messageinfo: [String:Any] = [
            "senderUID": uid,
            "otherName": otherName,
            "messageDate": unixtimestring,
            "messageKind": "text",
            "messageContent": messagestring,
            "messageID": message.messageId]
        
        //build new message
        
        let value: [String:Any] = [
            "messages": [messageinfo]
        ]
        
        //condense message into dictionary
        
        
        print(chatID)
        databaseadd.child("\(chatID)").setValue(value)
        
        //add dictionary to database
        
        
    }
    
    public func fetchChats(for otherUID: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
        guard let uid = (Auth.auth().currentUser?.uid) else {
            return
        }
        databaseadd.child("\(uid)/chats").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                print("cant fetch?")
                return
            }
            let chats: [Chat] = value.compactMap({ dictionary in
                let chatID = dictionary["chatID"]
                let latestMessage = dictionary["latestMessage"] as? [String: Any]
                let date = latestMessage?["date"] as? String
                let content = latestMessage?["messageContent"] as? String
                let otherUID = dictionary["otherUID"] as? String
                let otherName = dictionary["otherName"] as? String
                
                let recentMessage = recentMessage(date: date!, content: content!)
                
///                public struct Chat {
///                     let id: String
///                     let otherName: String
///                     let otherUID: String
///                     let recentMessage: recentMessage
///                 }
                
                print(Chat(id: chatID as! String, otherName: otherName ?? "OtherUser", otherUID: otherUID ?? "OtherUID", recentMessage: recentMessage))
                return Chat(id: chatID as! String, otherName: otherName ?? "OtherUser", otherUID: otherUID ?? "OtherUID", recentMessage: recentMessage)
            })
            
            completion(.success(chats))
                    
        })
    }
    
    public func sendMessage(to chatID: String, message: Message, otherName: String, otherUID: String, completion: @escaping(Bool) -> Void) {
        print(chatID)
        databaseadd.child("\(chatID)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            let strongSelf = self
            guard var existingMessages = snapshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            var messagestring = ""
            
            switch message.kind {
            case .text(let messageText):
                messagestring = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            //extracting raw string data from the message
            
            let date = message.sentDate
            let unixtime = Int(date.timeIntervalSince1970)
            let unixtimestring = String(unixtime)
            //https://stackoverflow.com/a/40496261
            
            //setup
            
            let uid = Auth.auth().currentUser!.uid as String
            
            //get UID
            
            let messageinfo: [String:Any] = [
                "senderUID": uid,
                "otherName": otherName,
                "messageDate": unixtimestring,
                "messageKind": "text",
                "messageContent": messagestring,
                "messageID": message.messageId]
            
            let recentmessage: [String:Any] = [
                "date": unixtimestring,
                "messageContent": messagestring]
            
            //build new message
            
            existingMessages.append(messageinfo)
            
            //Creates list of messages
            
            strongSelf!.databaseadd.child("\(chatID)/messages").setValue(existingMessages, withCompletionBlock: {error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
///                strongSelf?.databaseadd.child("\(uid)/chats/latestMessage").setValue(recentmessage, withCompletionBlock: {error, _ in
///                    guard error == nil else {
///                        completion(false)
///                        return
///                    }
///                })
                
                completion(true)
            })
        })
    }
    
    public func fetchChatsInChat(with chatID: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        databaseadd.child("\(chatID)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                print("cant fetch messages in chat?")
                return
            }
            let chats: [Message] = value.compactMap({ dictionary in
                guard let content = dictionary["messageContent"] as? String,
                      let date = dictionary["messageDate"] as? String,
                      let messageID = dictionary["messageID"] as? String,
                      let kind = dictionary["messageKind"] as? String,
                      let otherName = dictionary["otherName"] as? String,
                      let senderUID = dictionary["senderUID"] as? String else {
                          print("nil returned")
                          return nil
                }
                
                let dateint = Int(date)
                
                // convert Int to TimeInterval (typealias for Double)
                let timeInterval = TimeInterval(dateint!)

                // create NSDate from Double (NSTimeInterval)
                let dateFull = Date(timeIntervalSince1970: timeInterval)
                
                //https://stackoverflow.com/a/39934058
                print("message date is \(dateFull)")
                let sender = Sender(pfpURL: "", senderId: senderUID, displayName: otherName)
                return Message(sender: sender, messageId: messageID, sentDate: dateFull, kind: .text(content))
                
            })
            
            completion(.success(chats))
                    
        })
    }
    
    public func fetchUsername(userID: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.databaseadd.child("\(userID)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure("cant fetch username" as! Error))
                return
            }
            completion(.success(value))
        }
    }
    
//    public func isNewChat(chatID: String, completion: @escaping(Bool) -> Void) {
//        databaseadd.child("\(chatID)/messages").observe(.value, with: { snapshot in
//            guard let value = snapshot.value else {
//                completion(false)
//                return
//            }
//
//            completion(true)
//            return
//    }
    
    public func isNewChat(chatID: String, completion: @escaping(Bool) -> Void) {
        databaseadd.child("\(chatID)/messages").observe(.value, with: { snapshot in
            guard snapshot.value != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }

}

struct NewUser {
    let email: String
    let username: String
    let userID: String
    var profilePicName: String {
        return "images/\(userID)_profilepic.png"
    }
}

//Inserting to database: https://firebase.google.com/docs/database/ios/read-and-write, https://www.youtube.com/watch?v=rHo9EoscXow, https://firebase.google.com/docs, https://stackoverflow.com/questions/41355427/attempt-to-insert-non-property-list-object-when-trying-to-save-a-custom-object-i, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://riptutorial.com/ios/example/6436/get-unix-epoch-time, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://stackoverflow.com/questions/43477489/swift-ios-firebase-not-returning-any-data?rq=1, https://www.youtube.com/watch?v=qsBDL7fT8Mg, https://www.youtube.com/watch?v=Pu7B7uEzP18, https://firebase.google.com/support/release-notes/ios
