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
    
    @State var searchText = ""
    @State var sortingSelection: ListingSorting = .alphabeticAscending
    @State var currentUser: AppUser = previewUsers.first!
    
    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]
    
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    var body: some View {
        var listings: [ItemListing]
        
        if runningForPreviews {
            listings = previewItemListings
        } else {
            listings = env.listingRepository.itemListingsAToZ
        }
        
        // Filter by search text and starred
        let listingsFiltered = listings.filter {
            // First filter by search text...
            (searchText.isEmpty ||
             $0.name.lowercased().contains(searchText.lowercased()) ||
             $0.description.lowercased().contains(searchText.lowercased())
            )
            // ...then by user's starred items
            && currentUser.starredItems.contains($0.id!)
        }
        
        return NavigationView {
            VStack {
                if !env.authenticated {
                    Text("Please sign in to view starred listings")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                } else if listingsFiltered.isEmpty {
                    List {
                        HStack {
                            Spacer()
                            Text("You haven't starred any items yet\nStar an item from its page")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 25) {
                            ForEach(listingsFiltered, id: \.self) { listing in
                                NavigationLink(destination: ListingDetailView(item: listing)) {
                                    ItemListingBadge(item: listing)
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search Starred")
                }
            }
            .navigationTitle("Starred Listings")
        }
        .navigationViewStyle(.stack)
        .onAppear {
            guard !runningForPreviews else { return }
            
            if let currentUID = Auth.auth().currentUser?.uid {
                currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) ?? previewUsers.first!
            }
        }
    }
}

struct StarredListings_Previews: PreviewProvider {
    static var previews: some View {
        StarredListings()
            .environmentObject(EnvironmentObjects())
    }
}
