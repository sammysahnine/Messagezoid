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
import CryptoSwift

final class DatabaseController {
    static let shared = DatabaseController()
    private let databaseadd = Database.database().reference()
}

extension DatabaseController {
    //Builds a new user in the databsae
    public func UserBuilder(with user: NewUser, completion: @escaping (Bool) -> Void) {
        databaseadd.child(user.userID).setValue(["username": user.username, "email": user.email], withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
                //if error, return
            }
            
            self.databaseadd.child("UserList").observeSingleEvent(of: .value, with: { snapshot in
                if var UIDList = snapshot.value as? [[String: String]] {
                //Download the current user list
                    
                    let newUID = ["username": user.username, "UID": user.userID]
                    //get username and UID
                    
                    UIDList.append(newUID)
                    //add it to the pre-existing list of users
                    
                    
                    
                    self.databaseadd.child("UserList").setValue(UIDList, withCompletionBlock: { error, _ in
                    //Add the new appended list to the database
                        guard error == nil else {
                            completion(false)
                            return
                            //If error, return it to the user...
                        }
                        completion(true)
                        //... otherwise, pass completion
                    })
                }
                else {
                //If the userlist doesnt already exist...
                    let UIDList: [[String: String]] = [
                        ["username": user.username, "UID": user.userID]
                        //... create one...
                    ]
                    self.databaseadd.child("UserList").setValue(UIDList, withCompletionBlock: { error, _ in
                    //... and add the new user information
                        guard error == nil else {
                            completion(false)
                            return
                            //If error, return it to the user...
                        }
                        completion(true)
                        //... otherwise, pass completion
                    })
                }
            })
        })
    }
    
    //Creating user list: https://firebase.google.com/docs/auth/admin/manage-users, https://www.youtube.com/watch?v=qD582zfXlgo, https://www.youtube.com/watch?v=Hmr8PsG9E2w
    
    public func requestUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
        databaseadd.child("UserList").observeSingleEvent(of: .value, with: { snapshot in
        //Request users from the userlist
            guard let value  = snapshot.value as? [[String: String]] else {
            //List all information from users as a dictionary
                completion(.failure(FetchError.couldNotRequest))
                //If error, return it to the user...
                return
            }
            
            completion(.success(value))
            //... otherwise, pass completion
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
            //Varible initialisation
            
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
            //Setup for all message types
            //How to process each message
            
            let date = Date() // current date
            let unixtime = Int(date.timeIntervalSince1970)
            let unixtimestring = String(unixtime)
            //Making UNIX time a string: https://stackoverflow.com/a/40496261
            
            let chatID = "let_\(message.messageId)"
            //Setting up the chatID and making it unique for the chat
            
            messagestring = self!.encryptMessage(chatID: chatID, message: messagestring)
            //Encrypts the message using the message encryption function
            
            let newChatData = ["chatID": chatID, "otherUID": otherUID, "otherName": otherName, "latestMessage": ["messageContent": messagestring, "date": unixtimestring]] as [String : Any]
            
            //Gets all the chat information for the user that started the chat and formats it in such a way that the database can interpolate it
            
            let name = UserDefaults.standard.value(forKey: "name") as! String
            let otherNewChatData = ["chatID": chatID, "otherUID": uid, "otherName": name, "latestMessage": ["messageContent": messagestring, "date": unixtimestring]] as [String : Any]
            //Gets all the chat information for the user that did NOT start the chat and formats it in such a way that the database can interpolate it
            
            self?.databaseadd.child("\(otherUID)/chats").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var otherChats = snapshot.value as? [[String:Any]] {
                //If a chats folder already exists for the recipient...
                    otherChats.append(otherNewChatData)
                    self?.databaseadd.child("\(otherUID)/chats").setValue(otherChats)
                    //... append the chat data to the current list, and send it to the database, else...
                }
                else {
                    self?.databaseadd.child("\(otherUID)/chats").setValue([otherNewChatData])
                    //... add the data straight to the other user's chat folder (and create it in the process)
                }
            })
            
            if var chats = userFolder!["chats"] as? [[String: Any]] {
                //If a chats folder already exists for the sender...
                chats.append(newChatData)
                userFolder!["chats"] = chats
                refer.setValue(userFolder, withCompletionBlock: { [weak self] error, _ in
                //... append the chat data to the current list, and send it to the database, and...
                    guard error == nil else {
                        completion(false)
                        return
                        //(with a completion handler)
                    }
                self?.createChatFolder(chatID: chatID, otherName: otherName, message: message)
                //... create a main folder for all the messages in the chat, else...
                
                })
            }
            
            else {
                //... the folder does not exist, in which case...
                userFolder!["chats"] = [newChatData]
                refer.setValue(userFolder, withCompletionBlock: { [weak self] error, _ in
                // ... append the chat data to the current list, and send it to the database, and...
                    guard error == nil else {
                        completion(false)
                        return
                        //(with a completion handler)
                    }
                self?.createChatFolder(chatID: chatID, otherName: otherName, message: message)
                    //... create a main folder for all the messages in the chat.
                    
                })
            }
        })
    }
    
    private func createChatFolder(chatID: String, otherName: String, message: Message) {
        
        var messagestring = ""
        //Varible initialisation
        
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
        
        //Setup for all message types
        //How to process each message
        
        let date = message.sentDate
        let unixtime = Int(date.timeIntervalSince1970)
        let unixtimestring = String(unixtime)
        //Making UNIX time a string: https://stackoverflow.com/a/40496261
        
        let uid = Auth.auth().currentUser!.uid as String
        
        messagestring = self.encryptMessage(chatID: chatID, message: messagestring)
        //Encrypts the message using the message encryption function
        
        //Get current UID from Firebase
        
        let messageinfo: [String:Any] = [
            "senderUID": uid,
            "otherName": otherName,
            "messageDate": unixtimestring,
            "messageKind": "text",
            "messageContent": messagestring,
            "messageID": message.messageId]
        
        //Build a new message from the information got from the Chat View Contoller
        
        let value: [String:Any] = [
            "messages": [messageinfo]
        ]
        
        //Condense message into an array to make it easier to write to the database
    
        databaseadd.child("\(chatID)").setValue(value)
        
        //Add the array to the chat's database
        //Message has been added to the chat
    }
    
    public func fetchChats(for otherUID: String, completion: @escaping (Result<[Chat], Error>) -> Void) {
        guard let uid = (Auth.auth().currentUser?.uid) else {
        //Get the current userID from Firebase
            return
            //Return in the event of an error (such as no connection)
        }
        databaseadd.child("\(uid)/chats").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String:Any]] else {
                //Look in directory that the chats are in, and download as a dictionary
                print("cant fetch?")
                return
                //If you cannot fetch, print a debug statement, and return
            }
            let chats: [Chat] = value.compactMap({ dictionary in
                let chatID = dictionary["chatID"]
                let latestMessage = dictionary["latestMessage"] as? [String: Any]
                let date = latestMessage?["date"] as? String
                let content = self.decryptMessage(chatID: chatID as! String, message: (latestMessage?["messageContent"]) as! String)
                let otherUID = dictionary["otherUID"] as? String
                let otherName = dictionary["otherName"] as? String
                //Make 'chats' a dictionary consisting of multiple chat structures of all the messages in the entire chat
                
                let recentMessage = recentMessage(date: date!, content: content)
                //Let recentMessage equal the required data, for later updating
                
                print(Chat(id: chatID as! String, otherName: otherName ?? "OtherUser", otherUID: otherUID ?? "OtherUID", recentMessage: recentMessage))
                return Chat(id: chatID as! String, otherName: otherName ?? "OtherUser", otherUID: otherUID ?? "OtherUID", recentMessage: recentMessage)
                //Print debug statement and return the chats as a chat structure
            })
            
            completion(.success(chats))
            //Return completion statement
                    
        })
    }
    
    public func sendMessage(to chatID: String, message: Message, otherName: String, otherUID: String, completion: @escaping(Bool) -> Void) {
        databaseadd.child("\(chatID)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
        //Get existing messages from server
            let strongSelf = self
            guard var existingMessages = snapshot.value as? [[String:Any]] else {
            //Assign existing messages to variable, otherwise...
                completion(false)
                return
                //... return false completion
            }
            
            var messagestring = ""
            //Varible initialisation
            
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
            
            //Setup for all message types
            //How to process each message
            
            let date = message.sentDate
            let unixtime = Int(date.timeIntervalSince1970)
            let unixtimestring = String(unixtime)
            //Making UNIX time a string: https://stackoverflow.com/a/40496261
            
            let uid = Auth.auth().currentUser!.uid as String
            //Get current UID from Firebase
            
            messagestring = self!.encryptMessage(chatID: chatID, message: messagestring)
            //Encrypts the message using the message encryption function
            
            let messageinfo: [String:Any] = [
                "senderUID": uid,
                "otherName": otherName,
                "messageDate": unixtimestring,
                "messageKind": "text",
                "messageContent": messagestring,
                "messageID": message.messageId]
            
            //Build a new message from the information got from the Chat View Contoller
            
            let recentmessage: [String:Any] = [
                "date": unixtimestring,
                "messageContent": messagestring]
            //Build recent message data structure for use later (when changing most recent message)
            
            existingMessages.append(messageinfo)
            //Append the most recent message to the complete list of messages
            
            strongSelf!.databaseadd.child("\(chatID)/messages").setValue(existingMessages, withCompletionBlock: {error, _ in
            //Overwrite the existing list, with the new one, thus effectivly appending the new message to the list
                guard error == nil else {
                    completion(false)
                    return
                    //If there is an error, return false completion, else...
                }
                completion(true)
                //... return true completion
            })
        })
    }
    
    public func fetchChatsInChat(with chatID: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        databaseadd.child("\(chatID)/messages").observe(.value, with: { snapshot in
        //Download messages from the existing chat
            guard let value = snapshot.value as? [[String:Any]] else {
            //Assign these messages to a dictionary...
                print("cant fetch messages in chat?")
                return
                //... otherwise, return false completion
            }
            let chats: [Message] = value.compactMap({ dictionary in
                guard let encryptedContent = dictionary["messageContent"] as? String,
                      let content = self.decryptMessage(chatID: chatID, message: encryptedContent) as? String,
                      let date = dictionary["messageDate"] as? String,
                      let messageID = dictionary["messageID"] as? String,
                      let kind = dictionary["messageKind"] as? String,
                      let otherName = dictionary["otherName"] as? String,
                      let senderUID = dictionary["senderUID"] as? String else {
                          print("nil returned")
                          return nil
                }
                //Unwrap dictionary and turn into new one, readable by the application
                
                let dateint = Int(date)
                // convert Int to TimeInterval (typealias for Double)
                let timeInterval = TimeInterval(dateint!)
                // create NSDate from Double (NSTimeInterval)
                let dateFull = Date(timeIntervalSince1970: timeInterval)
                //Turn UNIX Timestamp String into workable date format: https://stackoverflow.com/a/39934058
                let sender = Sender(pfpURL: "", senderId: senderUID, displayName: otherName)
                //Set sender information
                return Message(sender: sender, messageId: messageID, sentDate: dateFull, kind: .text(content))
                //Return the messages in the chat, and then...
                
            })
            
            completion(.success(chats))
            //... pass completion
                    
        })
    }
    
    public func fetchUsername(userID: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.databaseadd.child("\(userID)").observeSingleEvent(of: .value) { snapshot in
        //Go into user folder, and fetch username
            guard let value = snapshot.value else {
            //Attempt to assign to a value, if unsuccessful, then...
                completion(.failure("cant fetch username" as! Error))
                return
                //... return failed completion, otherwise...
            }
            completion(.success(value))
            //... return sucessful completion
        }
    }
    
    public func isNewChat(chatID: String, completion: @escaping(Bool) -> Void) {
        databaseadd.child("\(chatID)/messages").observe(.value, with: { snapshot in
        //Attempt to download messgaes from a preexisting chat thorugh the chatID
            guard snapshot.value != nil else {
            //If there are no messages in the chat, then...
                completion(false)
                return
                //... return false completion, indicating that the chat is new, otherwise...
            }
            completion(true)
            //... return true completion, indicating that the chat is pre-existing.
        })
    }
    
    public func encryptMessage(chatID: String, message: String) -> String {
        let chatIDArray: [UInt8] = Array(chatID.utf8)
        let salt: [UInt8] = Array("mssgzoid".utf8)
        let key = try! PKCS5.PBKDF2(password: chatIDArray, salt: salt, iterations: 4096, keyLength: 16, variant: .sha256).calculate()
        
        do {
            let cipher = try? Rabbit(key: key)
            let base64 = try? message.encryptToBase64(cipher: cipher!)
            return base64!
        }
    }
    
    public func decryptMessage(chatID: String, message: String) -> String {
        let chatIDArray: [UInt8] = Array(chatID.utf8)
        let salt: [UInt8] = Array("mssgzoid".utf8)
        let key = try! PKCS5.PBKDF2(password: chatIDArray, salt: salt, iterations: 4096, keyLength: 16, variant: .sha256).calculate()
        
        do {
            let cipher = try? Rabbit(key: key)
            let decrypted = try? message.decryptBase64ToString(cipher: cipher!)
            return decrypted ?? "Error: Message could not be decrypted"
        }
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
//Structure for a new user, to help with insertion to database

//Special thanks to: https://firebase.google.com/docs/database/ios/read-and-write, https://www.youtube.com/watch?v=rHo9EoscXow, https://firebase.google.com/docs, https://stackoverflow.com/questions/41355427/attempt-to-insert-non-property-list-object-when-trying-to-save-a-custom-object-i, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://riptutorial.com/ios/example/6436/get-unix-epoch-time, https://stackoverflow.com/questions/49267834/swift-firebase-query-not-working, https://stackoverflow.com/questions/43477489/swift-ios-firebase-not-returning-any-data?rq=1, https://www.youtube.com/watch?v=qsBDL7fT8Mg, https://www.youtube.com/watch?v=Pu7B7uEzP18, https://firebase.google.com/support/release-notes/ios, https://en.wikipedia.org/wiki/PBKDF2, https://crypto.stackexchange.com/questions/48667/how-long-would-it-take-to-brute-force-an-aes-128-key, https://cryptoswift.io, https://github.com/krzyzanowskim/CryptoSwift, https://github.com/krzyzanowskim
