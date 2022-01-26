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
            completion(true)
        })
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

//Inserting to database: https://firebase.google.com/docs/database/ios/read-and-write, https://www.youtube.com/watch?v=rHo9EoscXow
