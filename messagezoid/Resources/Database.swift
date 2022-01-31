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
            }
            self.databaseadd.child("UserList").observeSingleEvent(of: .value, with: { snapshot in
                if var UIDList = snapshot.value as? [[String: String]] {
                    
                    let newUID = ["username": user.username, "UID": user.userID]
                    
                    UIDList.append(newUID)
                    
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

struct NewUser {
    let email: String
    let username: String
    let userID: String
    var profilePicName: String {
        return "\(userID)_profilepic.png"
    }
}

//Inserting to database: https://firebase.google.com/docs/database/ios/read-and-write, https://www.youtube.com/watch?v=rHo9EoscXow
