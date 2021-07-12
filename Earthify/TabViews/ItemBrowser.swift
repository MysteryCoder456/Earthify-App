//
//  ItemBrowser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import SwiftUI

struct ItemBrowser: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var searchText = ""

    let columns = [
        GridItem(.adaptive(minimum: 150)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        NavigationView {
            ScrollView {
                SearchBar(label: "Search for items...", text: $searchText)

                LazyVGrid(columns: columns, spacing: 25) {
                    let listings = runningForPreviews ? previewItemListings : env.listingRepository.itemListings

                    ForEach(listings.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) }, id: \.self) { listing in
                        ItemListingBadge(item: listing)
                    }
                }
            }
            .navigationTitle("Search Earthify")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {}) {
                            Label("New Item Listing", systemImage: "archivebox")
                        }
                    }
                    label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
        }
    }
}

struct ItemBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ItemBrowser()
            .environmentObject(EnvironmentObjects())
    }
}
