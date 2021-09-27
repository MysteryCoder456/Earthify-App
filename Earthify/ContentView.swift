//
//  ContentView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 09/07/2021.
//

import FirebaseAuth
import SwiftUI

/*
TODO:
 1. Allow users to browse listings without signing in.
 2. Change image selection button color in AddListingView.
 3. Sign in with Apple.
 4. Show starred items in a separate tab view.
*/

struct ContentView: View {
    @EnvironmentObject var env: EnvironmentObjects

    let themeColor = Color.green // (.sRGB, red: 0.39, green: 0.77, blue: 0.21, opacity: 1.0)

    var body: some View {
        if env.authenticated {
            HomeScreen()
                .accentColor(themeColor)
        } else {
            SplashScreen()
                .accentColor(themeColor)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(EnvironmentObjects())
    }
}
