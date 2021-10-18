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

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    let l_searchEarthify = NSLocalizedString("itembrowser.search_earthify", comment: "Search Earthify")
    let l_sortPickerLabel = NSLocalizedString("itembrowser.sort_picker_label", comment: "Sort Items")
    let l_sortPickerAccessibility = NSLocalizedString("itembrowser_acc.sort_picker_label", comment: "Sort Item Listings")
    let l_addItemLabel = NSLocalizedString("itembrowser.add_item_label", comment: "Add New Item")

    var body: some View {
        var listings: [ItemListing]

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
                    ForEach(listingsFiltered, id: \.id) { listing in
                        NavigationLink(destination: ListingDetailView(item: listing)) {
                            ItemListingBadge(item: listing)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: l_searchEarthify)
            .navigationTitle(l_searchEarthify)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Picker(l_sortPickerLabel, selection: $sortingSelection) {
                            ForEach(ListingSorting.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                    }
                    label: {
                        Label(l_sortPickerLabel, systemImage: "arrow.up.arrow.down")
                    }
                    .accessibility(label: Text(l_sortPickerAccessibility))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    if env.authenticated {
                        NavigationLink(destination: AddListingView()) {
                            Label(l_addItemLabel, systemImage: "plus")
                        }
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ItemBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ItemBrowser()
    }
}
