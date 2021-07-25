//
//  SettingsMenu.swift
//  Earthify
//
//  Created by Rehatbir Singh on 25/07/2021.
//

import GoogleSignIn
import SwiftUI

struct SettingsMenu: View {
    @State var showingSignOutAlert = false
    
    func signOut() {
        let si = GIDSignIn.sharedInstance()
        si?.signOut()
        si?.disconnect()
    }
    
    var body: some View {
        NavigationView {
            List {
                Button(action: { showingSignOutAlert = true }) {
                    Text("Sign Out")
                        .bold()
                        .foregroundColor(.red)
                }
                .alert(isPresented: $showingSignOutAlert) {
                    Alert(
                        title: Text("Are you sure you want to sign out?"),
                        primaryButton: .default(Text("Cancel")),
                        secondaryButton: .destructive(Text("Sign Out")) { signOut() }
                    )
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

struct SettingsMenu_Previews: PreviewProvider {
    static var previews: some View {
        SettingsMenu()
    }
}
