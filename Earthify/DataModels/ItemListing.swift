//
//  ItemListing.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import Foundation
import FirebaseFirestoreSwift

struct ItemListing: Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var ownerID: String
}

var previewItemListings = [
    ItemListing(name: "Item 1", description: "A cool item I don't need anymore.", ownerID: "1"),
    ItemListing(name: "Item 2", description: "Found this in my drawer the other day.", ownerID: "1"),
    ItemListing(name: "Item 3", description: "I bought this on accident. Please have take this.", ownerID: "2")
]
