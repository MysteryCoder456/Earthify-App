//
//  AppDelegate.swift
//  Earthify
//
//  Created by Rehatbir Singh on 09/07/2021.
//

import Firebase
import GoogleSignIn
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        // Initialize Firebase
        FirebaseApp.configure()

        // Initialize Google Sign In
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self

        return true
    }

    func sign(_: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // User attempts to Sign In

        if let error = error {
            print("Could not Sign In with Google: \(error.localizedDescription)")
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)

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

    func sign(_: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // User logs out...

        do {
            try Auth.auth().signOut()

            // User logs out successfully
            NotificationCenter.default.post(name: Notification.Name("UserSignedOut"), object: nil)
            print("User with email \(user.profile.email ?? "No Email") Signed Out")
        } catch {
            print("Could not Sign Out of Firebase: \(error.localizedDescription)")
        }
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options _: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
