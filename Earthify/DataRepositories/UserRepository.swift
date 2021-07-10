//
//  UserRepository.swift
//  Earthify
//
//  Created by Rehatbir Singh on 10/07/2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class UserRepository: ObservableObject {
    let db = Firestore.firestore()

    @Published var users: [AppUser] = []

    init() {
        readUsers()
    }

    func readUsers() {
        db.collection("users").addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                self.users = querySnapshot.documents.compactMap { document in
                    do {
                        let x = try document.data(as: AppUser.self)
                        return x
                    } catch {
                        print(error)
                    }

                    return nil
                }
            }
        }
    }

    func updateUser(user: AppUser) throws {
        if let uid = user.uid {
            // If the specified document does not exist, a new document will be created
            try db.collection("users").document(uid).setData(from: user)
        }
    }
}
