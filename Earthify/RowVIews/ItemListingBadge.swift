//
//  ItemListingBadge.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import FirebaseStorage
import SwiftUI

struct ItemListingBadge: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var itemImage = UIImage()

    let item: ItemListing
    let imageSize = CGSize(width: 170, height: 117)
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: runningForPreviews ? UIImage(named: "Preview \(item.name)")! : itemImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize.width, height: imageSize.height)
                .cornerRadius(15)
                .accessibility(hidden: true)

            Text(item.name)
                .font(.headline)
                .foregroundColor(.primary)
                .accessibility(label: Text("listingdetailview_acc.item_name \(item.name)", comment: "Name: name"))

            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibility(label: Text("listingdetailview_acc.item_description \(item.description)", comment: "Description: description"))
        }
        .lineLimit(1)
        .frame(width: imageSize.width)
        .accessibilityElement(children: .combine)
        .onAppear {
            guard !runningForPreviews else { return }
            
            // Get item image
            if let image = env.listingImageCache[item.id!] {
                // Image exists in cache
                itemImage = image
            } else {
                // Image does not exist in cache, fetch from Firebase Storage
                
                let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")
                let sizeLimit = env.listingImageMaximumSize

                storageRef.getData(maxSize: sizeLimit) { data, error in
                    if let error = error {
                        print("Could not fetch Item Listing image for \(item.id!): \(error.localizedDescription)")
                        return
                    }

                    if let data = data {
                        if let image = UIImage(data: data) {
                            env.listingImageCache[item.id!] = image  // Save to local cache
                            itemImage = image
                        }
                    }
                }
            }
        }
    }
}

struct ItemListingView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListingBadge(item: previewItemListings.first!)
    }
}
