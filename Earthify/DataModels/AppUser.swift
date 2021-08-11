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
    var profileImageURL: String?
    var starredItems: [String] = []
    
    func fullName() -> String {
        return "\(firstName) \(lastName)"
    }
}

let previewUsers = [
    // cool picture i know
    AppUser(uid: "1", firstName: "John", lastName: "Doe", email: "johndoe@gmail.com", profileImageURL: "https://cdn.discordapp.com/avatars/400857098121904149/293891e78a07321dfd61ba58898b86db.webp"),
    AppUser(uid: "2", firstName: "Joe", lastName: "Mama", email: "joemama@gmail.com"),
]
