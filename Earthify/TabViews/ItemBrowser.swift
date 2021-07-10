//
//  ItemBrowser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import SwiftUI

struct ItemBrowser: View {
    @EnvironmentObject var env: EnvironmentObjects
    
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    var body: some View {
        NavigationView {
            List(runningForPreviews ? previewItemListings : env.listingRepository.itemListings, id: \.self) { listing in
                Text(listing.name)
            }
            .navigationTitle("Search Earthify")
        }
    }
}

struct ItemBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ItemBrowser()
    }
}
