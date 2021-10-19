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
                        Text("settingsmenu.manage_listings", comment: "Manage listings")
                    }
                }

                NavigationLink(destination: AboutView()) {
                    Text("settingsmenu.about", comment: "About")
                }

                if env.authenticated {
                    Button(action: {
                        activeAlert = .signOut
                        showingAlert = true
                    }) {
                        Text("settingsmenu.sign_out", comment: "Sign Out")
                            .bold()
                            .foregroundColor(.red)
                    }
                } else {
                    Button(action: signInWithGoogle) {
                        Text("settingsmenu.google_sign_in", comment: "Sign in with Google")
                            .bold()
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationBarTitle(Text("settingsmenu.nav_title", comment: "Settings"), displayMode: .inline)
        }
        .navigationViewStyle(.stack)
        .alert(isPresented: $showingAlert) {
            let alert: Alert

            switch activeAlert {
            case .signIn:
                let currentUserEmail = (Auth.auth().currentUser?.email)!
                
                let l_title = NSLocalizedString("settingsmenu.sign_in_alert.success", comment: "Sign In Successful")
                let l_msg = NSLocalizedString("settingsmenu.sign_in_alert.success_msg \(currentUserEmail)", comment: "You have been signed in as \(currentUserEmail).")
                let l_dismissBtn = NSLocalizedString("settingsmenu.sign_in_alert.dismiss", comment: "OK")
                
                alert = Alert(
                    title: Text(l_title),
                    message: Text(l_msg),
                    dismissButton: .default(Text(l_dismissBtn))
                )

            case .signOut:
                let l_title = NSLocalizedString("settingsmenu.sign_out_alert", comment: "Are you sure you want to sign out?")
                let l_cancelBtn = NSLocalizedString("settingsmenu.sign_out_alert.cancel", comment: "Cancel")
                let l_signOutBtn = NSLocalizedString("settingsmenu.sign_out_alert.sign_out", comment: "Sign Out")
                
                alert = Alert(
                    title: Text(l_title),
                    primaryButton: .default(Text(l_cancelBtn)),
                    secondaryButton: .destructive(Text(l_signOutBtn), action: signOut)
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
