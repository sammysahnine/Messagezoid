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
    public func startNewChat(with otherUID: String, message: Message, completion: @escaping(Bool) -> Void) {
        let uid = (Auth.auth().currentUser?.uid)!
        let refer = databaseadd.child("\(uid)")
        //get uid and make directory path
        refer.observeSingleEvent(of: .value, with: { snapshot in
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
            
            
            let newChatData = ["chatID": chatID, "otherUID": otherUID, "first_message": ["message_content": messagestring, "date": unixtimestring]] as [String : Any]
            
            if var chats = userFolder!["chats"] as? [[String: Any]] {
                //conversation exists
                chats.append(newChatData)
                userFolder?["chats"] = [newChatData]
                refer.setValue(userFolder)
                self.createMasterNode(chatID: chatID, message: message)
                
                //Add data to the chat
                
            }
            else {
                //doesnt exist
                userFolder?["chats"] = [newChatData]
                refer.setValue(userFolder)
                self.createMasterNode(chatID: chatID, message: message)
                
                //make direectory and add it to the chat
            }
        })
    }
    
    private func createMasterNode(chatID: String, message: Message) {
        
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
    
    public func fetchChats(with otherUID: String) {
        
    }
    
    public func sendMessage(to: String, message: Message, completion: @escaping(Bool) -> Void) {
        
    }
}



struct NewUser {
    let email: String
    let username: String
    let userID: String
    var profilePicName: String {
        return "\(userID)_profilepic.png"
    }
}

//Inserting to database: https://firebase.google.com/docs/database/ios/read-and-write, https://www.youtube.com/watch?v=rHo9EoscXow, https://firebase.google.com/docs, https://stackoverflow.com/questions/41355427/attempt-to-insert-non-property-list-object-when-trying-to-save-a-custom-object-i, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://riptutorial.com/ios/example/6436/get-unix-epoch-time, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://stackoverflow.com/questions/43477489/swift-ios-firebase-not-returning-any-data?rq=1, https://www.youtube.com/watch?v=qsBDL7fT8Mg, https://www.youtube.com/watch?v=Pu7B7uEzP18, https://firebase.google.com/support/release-notes/ios
