//
//  AppUser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 10/07/2021.
//

import FirebaseFirestoreSwift
import Foundation

struct AppUser: Codable {
    @DocumentID var uid: String? // This is the user's UID which is assigned by Firebase Authentication
    var firstName: String
    var lastName: String
    var email: String
}

var previewUsers = [
    AppUser(uid: "1", firstName: "John", lastName: "Doe", email: "johndoe@gmail.com"),
    AppUser(uid: "2", firstName: "Joe", lastName: "Mama", email: "joemama@gmail.com"),
]
