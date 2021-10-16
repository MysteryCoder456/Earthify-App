//
//  EnvironmentObjects.swift
//  Earthify
//
//  Created by Rehatbir Singh on 16/10/2021.
//

import Combine
import FirebaseAuth
import GoogleSignIn

class EnvironmentObjects: ObservableObject {
    @Published var authenticated: Bool
    @Published var seenSplashScreen: Bool // exists for dismissing SplashScreen without changing authenticated flag
    @Published var userRepository: UserRepository!
    @Published var listingRepository: ItemListingRepository!
    @Published var messageRepository: MessageRepository!
    
    let googleAuthHandler = GoogleAuthHandler()
    
    let listingImageMaximumSize: Int64 = 3_145_728 // bytes
    var userRepoCancellable: AnyCancellable?
    var listingRepoCancellable: AnyCancellable?
    var messageRepoCancellable: AnyCancellable?
    
    var listingImageCache: [String: UIImage] = [:]
    
    init() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            googleAuthHandler.restorePreviousSignIn()
        }
        
        authenticated = Auth.auth().currentUser != nil
        seenSplashScreen = Auth.auth().currentUser != nil
        
        // Initialize Firestore Respositories
        userRepository = UserRepository()
        listingRepository = ItemListingRepository()
        messageRepository = MessageRepository()
        
        // Notify EnvironmentObjects when published repository attributes change
        userRepoCancellable = userRepository.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        listingRepoCancellable = listingRepository.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        messageRepoCancellable = messageRepository.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        
        // Listen for Sign In and Sign Out notifications
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(didUserSignIn), name: Notification.Name("UserSignedIn"), object: nil)
        nc.addObserver(self, selector: #selector(didUserSignOut), name: Notification.Name("UserSignedOut"), object: nil)
    }
    
    func initRepositories() {
        userRepository = UserRepository()
        listingRepository = ItemListingRepository()
        messageRepository = MessageRepository()
        
        // Notify EnvironmentObjects when published repository attributes change
        userRepoCancellable = userRepository.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        listingRepoCancellable = listingRepository.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
        messageRepoCancellable = messageRepository.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }
    
    @objc func didUserSignIn() {
        authenticated = true
        
        // Add/Update user details in Firestore
        
        if let currentUID = Auth.auth().currentUser?.uid {
            if let googleProfile = GIDSignIn.sharedInstance.currentUser?.profile {
                // Initialize Firestore Respositories
                initRepositories()
                
                let userHasImage = googleProfile.hasImage
                let imageURL = userHasImage ? googleProfile.imageURL(withDimension: 128)?.absoluteString : nil
                
                var user = AppUser(uid: currentUID, firstName: googleProfile.givenName!, lastName: googleProfile.familyName!, email: googleProfile.email, profileImageURL: imageURL)
                
                // Preserve user details not related to Google Account
                if let existingUserEntry = userRepository.users.first(where: { $0.uid == currentUID }) {
                    user.starredItems = existingUserEntry.starredItems
                }
                
                do {
                    try userRepository.updateUser(user: user)
                } catch {
                    print("Failed to update user details in Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func didUserSignOut() {
        authenticated = false
    }
}
