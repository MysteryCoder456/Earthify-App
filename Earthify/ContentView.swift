//
//  ContentView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 09/07/2021.
//

import FirebaseAuth
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var env: EnvironmentObjects

    var body: some View {
        if env.authenticated {
            HomeScreen()
        } else {
            SplashScreen()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
