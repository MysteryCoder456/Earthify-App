//
//  StarredListings.swift
//  Earthify
//
//  Created by Rehatbir Singh on 14/10/2021.
//

import FirebaseAuth
import SwiftUI

struct StarredListings: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var starredListings: [ItemListing] = []
    @State var searchText = ""

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    let l_searchPrompt = NSLocalizedString("starredlistings.search_prompt", comment: "Search Starred")

    func fetchStarredListings() {
        guard !runningForPreviews else {
            starredListings = previewStarredListings
            return
        }

        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let currentUser = env.userRepository.users.first(where: { $0.uid == currentUID })!

        // Filter by search text and starred
        starredListings = env.listingRepository.itemListingsAToZ.filter {
            // First filter by search text...
            (searchText.isEmpty ||
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
            )
                // ...then by user's starred items
                && currentUser.starredItems.contains($0.id!)
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if !env.authenticated {
                    Text("starredlistings.sign_in_msg", comment: "Please sign in to view starred listings")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                } else if starredListings.isEmpty {
                    List {
                        HStack {
                            Spacer()
                            Text("starredlistings.no_stars_msg", comment: "You haven't starred any items yet\nStar an item from its page")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                    .refreshable { fetchStarredListings() }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 25) {
                            ForEach(starredListings, id: \.self) { listing in
                                NavigationLink(destination: ListingDetailView(item: listing)) {
                                    ItemListingBadge(item: listing)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: l_searchPrompt)
                }
            }
            .navigationTitle(Text("starredlistings.nav_title", comment: "Starred Listings"))
        }
        .navigationViewStyle(.stack)
        .onAppear { fetchStarredListings() }
    }
}

struct StarredListings_Previews: PreviewProvider {
    static var previews: some View {
        StarredListings()
            .environmentObject(EnvironmentObjects())
    }
}
