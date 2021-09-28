//
//  ItemBrowser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import CoreLocation
import FirebaseAuth
import SwiftUI

enum ListingSorting: String, CaseIterable {
    case alphabeticAscending = "A to Z"
    case alphabeticDescending = "Z to A"

    case distanceAscending = "Nearest First"
}

struct ItemBrowser: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var searchText = ""
    @State var sortingSelection: ListingSorting = .alphabeticAscending
    @State var viewStarred = false

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        var currentUser: AppUser = previewUsers.first!
        var listings: [ItemListing]

        if !runningForPreviews {
            if let currentUID = Auth.auth().currentUser?.uid {
                currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) ?? previewUsers.first!
            }
        }

        if runningForPreviews {
            listings = previewItemListings
        } else {
            // Check location authorization
            let locationManager = CLLocationManager()
            let locationAuthorization = locationManager.authorizationStatus
            let canGetLocation = (locationAuthorization == .authorizedAlways || locationAuthorization == .authorizedWhenInUse)

            switch sortingSelection {
            case .alphabeticAscending:
                listings = env.listingRepository.itemListingsAToZ

            case .alphabeticDescending:
                listings = env.listingRepository.itemListingsZToA

            case .distanceAscending:
                listings = env.listingRepository.itemListingsAToZ.sorted(by: { firstListing, secondListing in
                    if canGetLocation {
                        if let currentLocation = locationManager.location {
                            let firstGeoPoint = firstListing.location
                            let firstLocation = CLLocation(latitude: firstGeoPoint.latitude, longitude: firstGeoPoint.longitude)
                            let firstDistance = firstLocation.distance(from: currentLocation)

                            let secondGeoPoint = secondListing.location
                            let secondLocation = CLLocation(latitude: secondGeoPoint.latitude, longitude: secondGeoPoint.longitude)
                            let secondDistance = secondLocation.distance(from: currentLocation)

                            return firstDistance < secondDistance
                        }
                    }
                    return 0 < 1
                })
            }
        }

        // Filter by search text
        let listingsFiltered = listings.filter {
            searchText.isEmpty ||
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.description.lowercased().contains(searchText.lowercased())
        }

        return NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 25) {
                    ForEach(listingsFiltered, id: \.self) { listing in
                        let itemIsStarred = currentUser.starredItems.contains(listing.id!)

                        if viewStarred == itemIsStarred || !viewStarred {
                            NavigationLink(destination: ListingDetailView(item: listing)) {
                                ItemListingBadge(item: listing)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Earthify")
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
                    if env.authenticated {
                        NavigationLink(destination: AddListingView()) {
                            Label("New Item Listing", systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
}

struct ItemBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ItemBrowser()
    }
}
