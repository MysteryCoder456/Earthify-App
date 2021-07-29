//
//  ItemListing.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import FirebaseFirestoreSwift
import Foundation

struct ItemListing: Codable, Hashable {
    @DocumentID var id = UUID().uuidString
    var name: String
    var description: String
    var ownerID: String
}

var previewItemListings = [
    ItemListing(id: "1", name: "Item 1", description: "A cool item I don't need anymore.", ownerID: "1"),
    ItemListing(id: "2", name: "Item 2", description: "Found this in my drawer the other day.", ownerID: "1"),
    ItemListing(id: "3", name: "Item 3", description: "Vintage hardware that I used 20 years ago.", ownerID: "2"),
]
