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
    var imagePath: String
}

var previewItemListings = [
    ItemListing(name: "Item 1", description: "A cool item I don't need anymore.", ownerID: "1", imagePath: "Preview Item 1"),
    ItemListing(name: "Item 2", description: "Found this in my drawer the other day.", ownerID: "1", imagePath: "Preview Item 2"),
    ItemListing(name: "Item 3", description: "Vintage hardware that I used 20 years ago.", ownerID: "2", imagePath: "Preview Item 3")
]
