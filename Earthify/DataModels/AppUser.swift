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
}

let previewUsers = [
    // cool picture i know
    AppUser(uid: "1", firstName: "John", lastName: "Doe", email: "johndoe@gmail.com", profileImageURL: "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fupload.wikimedia.org%2Fwikipedia%2Fen%2F1%2F1e%2FDerpTrolling_logo_200x200.png&f=1&nofb=1"),
    AppUser(uid: "2", firstName: "Joe", lastName: "Mama", email: "joemama@gmail.com"),
]
