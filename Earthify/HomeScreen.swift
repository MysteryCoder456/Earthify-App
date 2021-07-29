//
//  HomeScreen.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import SwiftUI

struct HomeScreen: View {
    var body: some View {
        TabView {
            ItemBrowser()
                .tabItem {
                    Label("Item Browser", systemImage: "magnifyingglass")
                }

            SettingsMenu()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
