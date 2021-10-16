//
//  ItemListing.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import CoreLocation
import Firebase
import FirebaseFirestoreSwift
import Foundation

struct ItemListing: Codable, Hashable {
    @DocumentID var id = UUID().uuidString
    var name: String
    var description: String
    var ownerID: String
    var location: GeoPoint
}

private let blankGeoPoint = GeoPoint(latitude: 0, longitude: 0)
let previewItemListings = [
    ItemListing(id: "1", name: "Item 1", description: "A cool item I don't need anymore.", ownerID: "1", location: blankGeoPoint),
    ItemListing(id: "2", name: "Item 2", description: "Found this in my drawer the other day.", ownerID: "1", location: blankGeoPoint),
    ItemListing(id: "3", name: "Item 3", description: "Vintage hardware that I used 20 years ago.", ownerID: "2", location: blankGeoPoint),
]
let previewStarredListings = Array(previewItemListings[0...2])
