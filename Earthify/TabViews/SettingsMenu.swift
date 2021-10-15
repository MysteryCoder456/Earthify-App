//
//  SettingsMenu.swift
//  Earthify
//
//  Created by Rehatbir Singh on 25/07/2021.
//

import FirebaseAuth
import SwiftUI

private class NotificationHandler: ObservableObject {
    var source: () -> Void = {}

    init(notificationName: String) {
        // Listen for user sign in
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(invoke),
            name: Notification.Name(notificationName),
            object: nil
        )
    }

    func setSource(source: @escaping () -> Void) {
        self.source = source
    }

    @objc func invoke() {
        source()
    }
}

private enum ActiveAlert {
    case signIn
    case signOut
}

struct SettingsMenu: View {
    @EnvironmentObject var env: EnvironmentObjects

    @State private var activeAlert = ActiveAlert.signIn
    @State var showingAlert = false

    @StateObject private var signInAlertCaller = NotificationHandler(notificationName: "UserSignedIn")

    func signInWithGoogle() {
        env.googleAuthHandler.signInWithGoogle()
    }

    func signOut() {
        env.googleAuthHandler.signOut()
    }

    func showSignInAlert() {
        activeAlert = .signIn
        showingAlert = true
    }

    var body: some View {
        NavigationView {
            List {
                if env.authenticated {
                    NavigationLink(destination: ManageListingsView()) {
                        Text("Manage listings")
                    }
                }

                NavigationLink(destination: AboutView()) {
                    Text("About")
                }

                if env.authenticated {
                    Button(action: {
                        activeAlert = .signOut
                        showingAlert = true
                    }) {
                        Text("Sign Out")
                            .bold()
                            .foregroundColor(.red)
                    }
                } else {
                    Button(action: signInWithGoogle) {
                        Text("Sign in with Google")
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
        .navigationViewStyle(.stack)
        .alert(isPresented: $showingAlert) {
            let alert: Alert

            switch activeAlert {
            case .signIn:
                let currentUserEmail = (Auth.auth().currentUser?.email)!
                alert = Alert(
                    title: Text("Sign In Successful"),
                    message: Text("You have been signed in as \(currentUserEmail)."),
                    dismissButton: .default(Text("OK"))
                )

            case .signOut:
                alert = Alert(
                    title: Text("Are you sure you want to sign out?"),
                    primaryButton: .default(Text("Cancel")),
                    secondaryButton: .destructive(Text("Sign Out"), action: signOut)
                )
            }

            return alert
        }
        .onAppear {
            signInAlertCaller.setSource(source: self.showSignInAlert)
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
