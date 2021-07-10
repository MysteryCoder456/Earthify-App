//
//  UserRepository.swift
//  Earthify
//
//  Created by Rehatbir Singh on 10/07/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserRepository: ObservableObject {
    let db = Firestore.firestore()

    @Published var users: Array<AppUser> = []
    
    init() {
        readUsers()
    }

    func createUser(user: AppUser) {
        do {
            let _ = try db.collection("users").addDocument(from: user)
        } catch {
            print(error)
        }
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
