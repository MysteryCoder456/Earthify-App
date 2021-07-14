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
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        NavigationView {
            ScrollView {
                SearchBar(label: "Search for items...", text: $searchText)
                    .padding([.horizontal, .bottom], 10)

                LazyVGrid(columns: columns, spacing: 25) {
                    let listings = runningForPreviews ? previewItemListings : env.listingRepository.itemListings

                    ForEach(listings.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) }, id: \.self) { listing in
                        NavigationLink(destination: ListingDetailView(item: listing)) {
                            ItemListingBadge(item: listing)
                        }
                    }
                }
            }
            .navigationTitle("Search Earthify")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // TODO: Add item listing sorting
                        Text("Sorting Coming Soon...")
                    }
                    label: {
                        Label("Add", systemImage: "arrow.up.arrow.down")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddListingView()) {
                        Label("New Item Listing", systemImage: "plus")
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
