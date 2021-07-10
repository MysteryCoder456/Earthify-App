//
//  ItemListingRepository.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

class ItemListingRepository: ObservableObject {
    let db = Firestore.firestore()

    @Published var itemListings: [ItemListing] = []

    init() {
        readListings()
    }

    func readListings() {
        db.collection("listings").addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                self.itemListings = querySnapshot.documents.compactMap { document in
                    do {
                        let x = try document.data(as: ItemListing.self)
                        return x
                    } catch {
                        print(error)
                    }

                    return nil
                }
            }
        }
    }

    func updateListing(listing: ItemListing) throws {
        if let listingID = listing.id {
            // If the specified document does not exist, a new document will be created
            try db.collection("listing").document(listingID).setData(from: listing)
        }
    }
}
