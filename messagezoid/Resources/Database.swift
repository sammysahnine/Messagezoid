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
    public func UserBuilder(with user: NewUser) {
        databaseadd.child(user.userID).setValue(["username": user.username, "email": user.email])
    }
}

struct NewUser {
    let email: String
    let username: String
    let userID: String
}

//Inserting to database: https://firebase.google.com/docs/database/ios/read-and-write
