//
//  ItemBrowser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import FirebaseAuth
import SwiftUI

enum ListingSorting: String, CaseIterable {
    case alphabetic = "A to Z"
    case alphabeticReversed = "Z to A"
}

struct ItemBrowser: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var searchText = ""
    @State var sortingSelection: ListingSorting = .alphabetic
    @State var viewStarred = false

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        var listings: [ItemListing]

        if runningForPreviews {
            listings = previewItemListings
        } else {
            switch sortingSelection {
            case .alphabetic:
                listings = env.listingRepository.itemListingsAToZ
            case .alphabeticReversed:
                listings = env.listingRepository.itemListingsZToA
            }
        }

        return NavigationView {
            ScrollView {
                SearchBar(label: "Search for items...", text: $searchText)
                    .padding([.horizontal, .bottom], 10)

                LazyVGrid(columns: columns, spacing: 25) {
                    let currentUID = Auth.auth().currentUser!.uid
                    if let currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) {
                        ForEach(listings.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) }, id: \.self) { listing in
                            let itemIsStarred = currentUser.starredItems.contains(listing.id!)

                            if viewStarred == itemIsStarred || !viewStarred {
                                NavigationLink(destination: ListingDetailView(item: listing)) {
                                    ItemListingBadge(item: listing)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Earthify")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker("Sort Listings", selection: $sortingSelection) {
                            ForEach(ListingSorting.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                    }
                    label: {
                        Label("Add", systemImage: "arrow.up.arrow.down")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { viewStarred.toggle() }) {
                        Label("View Starred", systemImage: viewStarred ? "star.fill" : "star")
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
