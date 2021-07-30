//
//  MessageRepository.swift
//  Earthify
//
//  Created by Rehatbir Singh on 29/07/2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Foundation

class MessageRepository: ObservableObject {
    let db = Firestore.firestore()
    
    @Published var messages: [Message] = []
    
    init() {
        readMessages()
    }
    
    func readMessages() {
        // Make user is logged in
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        // Only fetch messages that the current user is related to
        db.collection("messages")
            .order(by: "dateSent")
            .whereField("recipients", arrayContains: currentUID)
            .addSnapshotListener { querySnapshot, error in
                if let querySnapshot = querySnapshot {
                    self.messages = querySnapshot.documents.compactMap { document in
                        do {
                            let x = try document.data(as: Message.self)
                            return x
                        } catch {
                            print("Could not fetch message document: \(error.localizedDescription)")
                        }
                        
                        return nil
                    }
                }
            }
    }
    
    func updateMessage(_ message: Message) throws {
        if let messageID = message.id {
            // If the specified document does not exist, a new document will be created
            try db.collection("messages").document(messageID).setData(from: message)
        }
    }
    
    func deleteMessage(_ message: Message) {
        if let messageID = message.id {
            db.collection("messages").document(messageID).delete()
        }
    }
}

