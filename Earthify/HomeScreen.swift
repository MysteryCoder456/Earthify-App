//
//  HomeScreen.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import CoreLocation
import SwiftUI

struct HomeScreen: View {
    var body: some View {
        TabView {
            ItemBrowser()
                .tabItem {
                    Label("Item Browser", systemImage: "magnifyingglass")
                }

            ChatsBrowser()
                .tabItem {
                    Label("Chats", systemImage: "message.fill")
                }

            SettingsMenu()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            // Request Location Services
            let locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
