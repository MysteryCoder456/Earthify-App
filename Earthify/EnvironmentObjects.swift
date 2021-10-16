//
//  EnvironmentObjects.swift
//  Earthify
//
//  Created by Rehatbir Singh on 16/10/2021.
//

import Combine
import FirebaseAuth
import FirebaseFirestore
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
                
                // Manually fetching Firestore data in case repositories haven't initialized in time
                let docRef = Firestore.firestore().collection("users").document(currentUID)
                docRef.getDocument { document, error in
                    if let error = error {
                        print("Unable to fetch user data. Error: \(error)")
                        return
                    }
                    
                    guard let document = document else { return }
                    
                    let userHasImage = googleProfile.hasImage
                    let imageURL = userHasImage ? googleProfile.imageURL(withDimension: 128)?.absoluteString : nil
                    var user = AppUser(firstName: "", lastName: "", email: "")
                    
                    if document.exists {
                        do {
                            user = try document.data(as: AppUser.self)!
                            
                            // Update Google Profile details
                            user.firstName = googleProfile.givenName!
                            user.lastName = googleProfile.familyName!
                            user.email = googleProfile.email
                            user.profileImageURL = imageURL
                        } catch {
                            print("Failed to decode document as AppUser. Error: \(error.localizedDescription)")
                        }
                    } else {
                        user = AppUser(uid: currentUID, firstName: googleProfile.givenName!, lastName: googleProfile.familyName!, email: googleProfile.email, profileImageURL: imageURL)
                    }
                    
                    do {
                        try self.userRepository.updateUser(user: user)
                    } catch {
                        print("Failed to update user details in Firestore. Error: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc func didUserSignOut() {
        authenticated = false
    }
}
