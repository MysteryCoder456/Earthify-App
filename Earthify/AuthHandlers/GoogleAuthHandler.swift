//
//  GoogleAuthHandler.swift
//  Earthify
//
//  Created by Rehatbir Singh on 12/10/2021.
//

import Firebase
import Foundation
import GoogleSignIn
import UIKit

class GoogleAuthHandler: ObservableObject {
    private func didUserSignIn(didSignInFor user: GIDGoogleUser?, withError error: Error?) {
        // User attempts to Sign In

        if let error = error {
            print("Could not Sign In with Google: \(error.localizedDescription)")
            return
        }

        guard let user = user else { return }

        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken!, accessToken: user.authentication.accessToken)

        // Logging into Firebase

        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("Could not Sign into Firebase: \(error.localizedDescription)")
                return
            }

            // User Signed In successfully
            NotificationCenter.default.post(name: Notification.Name("UserSignedIn"), object: nil)

            print("User Signed In with email: \(result?.user.email ?? "No Email")")
        }
    }

    private func didUserSignOut(withError error: Error?) {
        // User logs out...

        do {
            try Auth.auth().signOut()

            // User logs out successfully
            NotificationCenter.default.post(name: Notification.Name("UserSignedOut"), object: nil)
            print("User Signed Out")
        } catch {
            print("Could not Sign Out. Error: \(error.localizedDescription)")
        }
    }

//    private func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        GIDSignIn.sharedInstance.handle(url)
//    }

    func signInWithGoogle() {
        let configuration = GIDConfiguration(clientID: (FirebaseApp.app()?.options.clientID)!)
        GIDSignIn.sharedInstance.signIn(with: configuration, presenting: (UIApplication.shared.keyWindow?.rootViewController)!, callback: didUserSignIn)
    }

    func signOut() {
        let si = GIDSignIn.sharedInstance
        si.signOut()
        si.disconnect(callback: didUserSignOut)
    }

    func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn(callback: didUserSignIn)
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
