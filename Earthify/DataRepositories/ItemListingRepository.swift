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

    @Published var itemListingsAToZ: [ItemListing] = []
    @Published var itemListingsZToA: [ItemListing] = []

    init() {
        readListingsAToZ()
        readListingsZToA()
    }

    func readListingsAToZ() {
        db.collection("listings").order(by: "name").addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                self.itemListingsAToZ = querySnapshot.documents.compactMap { document in
                    do {
                        let x = try document.data(as: ItemListing.self)
                        return x
                    } catch {
                        print("Could not fetch listing document: \(error.localizedDescription)")
                    }

                    return nil
                }
            }
        }
    }

    func readListingsZToA() {
        db.collection("listings").order(by: "name", descending: true).addSnapshotListener { querySnapshot, error in
            if let querySnapshot = querySnapshot {
                self.itemListingsZToA = querySnapshot.documents.compactMap { document in
                    do {
                        let x = try document.data(as: ItemListing.self)
                        return x
                    } catch {
                        print("Could not fetch listing document: \(error.localizedDescription)")
                    }

                    return nil
                }
            }
        }
    }

    func updateListing(listing: ItemListing) throws {
        if let listingID = listing.id {
            // If the specified document does not exist, a new document will be created
            try db.collection("listings").document(listingID).setData(from: listing)
        }
    }

    func deleteListing(listing: ItemListing) {
        if let listingID = listing.id {
            db.collection("listings").document(listingID).delete()
        }
    }
}
