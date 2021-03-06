//
//  User.swift
//  ToDoFIRE
//
//  Created by Никита Коголенок on 6.03.21.
//

import Foundation
import Firebase

struct AppUser {
    let uid: String
    let email: String
    
    init(user: User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
