//
//  ManageListingsView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 26/07/2021.
//

import FirebaseAuth
import SwiftUI

struct ManageListingsView: View {
    @EnvironmentObject var env: EnvironmentObjects

    let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 175)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        var listings: [ItemListing]

        if runningForPreviews {
            listings = previewItemListings
        } else {
            let currentUID = Auth.auth().currentUser?.uid
            listings = env.listingRepository.itemListingsAToZ.filter {
                $0.ownerID == currentUID
            }
        }

        return ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(listings, id: \.self) { listing in
                    NavigationLink(destination: EditListingView(item: listing)) {
                        ItemListingBadge(item: listing)
                    }
                }
            }
        }
        .navigationBarTitle("Manage Listings")
    }
}

struct ManageListingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ManageListingsView()
        }
    }
}
