//
//  Message.swift
//  Earthify
//
//  Created by Rehatbir Singh on 29/07/2021.
//

import FirebaseFirestoreSwift
import Foundation

struct Message: Codable {
    @DocumentID var id = UUID().uuidString
    var senderID: String
    var receiverID: String
    var content: String
    var dateSent = Date()
}

let previewMessages = [
    Message(senderID: "1", receiverID: "2", content: "Hi, I want this."),
    Message(senderID: "2", receiverID: "1", content: "You want what?"),
    Message(senderID: "1", receiverID: "2", content: "I want this cool thing."),
]