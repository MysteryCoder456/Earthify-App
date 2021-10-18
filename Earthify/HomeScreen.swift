//
//  HomeScreen.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import CoreLocation
import SwiftUI

struct HomeScreen: View {
    let l_itemBrowser = NSLocalizedString("homescreen.item_browser", comment: "Item Browser")
    let l_starred = NSLocalizedString("homescreen.starred", comment: "Starred")
    let l_chats = NSLocalizedString("homescreen.chats", comment: "Chats")
    let l_settings = NSLocalizedString("homescreen.settings", comment: "Settings")
    
    var body: some View {
        TabView {
            ItemBrowser()
                .tabItem {
                    Label(l_itemBrowser, systemImage: "magnifyingglass")
                }

            StarredListings()
                .tabItem {
                    Label(l_starred, systemImage: "star.fill")
                }

            ChatsBrowser()
                .tabItem {
                    Label(l_chats, systemImage: "message.fill")
                }

            SettingsMenu()
                .tabItem {
                    Label(l_settings, systemImage: "gear")
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
