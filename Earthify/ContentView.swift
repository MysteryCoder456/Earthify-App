//
//  ContentView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 09/07/2021.
//

import FirebaseAuth
import SwiftUI

// Forgive this global variable I didn't know how else to make it available
// everywhere without Environment Objects
let themeColor = Color.green //(.sRGB, red: 0.39, green: 0.77, blue: 0.21, opacity: 1.0)

struct ContentView: View {
    @EnvironmentObject var env: EnvironmentObjects

    var body: some View {
        if env.authenticated {
            HomeScreen()
                .accentColor(themeColor)
        } else {
            SplashScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(EnvironmentObjects())
    }
}
