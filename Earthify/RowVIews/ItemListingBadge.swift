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

            Text(item.name)
                .font(.headline)

            Text(item.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(width: imageSize.width)
        .onAppear {
            if !runningForPreviews {
                let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")
                let sizeLimit = env.listingImageMaximumSize

                storageRef.getData(maxSize: sizeLimit) { data, error in
                    if let error = error {
                        print("Could not fetch Item Listing image for \(item.id!): \(error.localizedDescription)")
                        return
                    }

                    if let data = data {
                        if let image = UIImage(data: data) {
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
