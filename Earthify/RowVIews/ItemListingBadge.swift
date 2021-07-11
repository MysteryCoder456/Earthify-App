//
//  ItemListingBadge.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import SwiftUI

struct ItemListingBadge: View {
    @State var itemImage = UIImage()
    
    let item: ItemListing
    let imageSize = CGSize(width: 160, height: 110)
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(uiImage: runningForPreviews ? UIImage(named: item.imagePath)! : itemImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize.width, height: imageSize.height)
                .cornerRadius(15)
            
            Text(item.name)
                .font(.headline)
            
            Text(item.description)
                .font(.caption)
        }
        .frame(width: imageSize.width)
    }
}

struct ItemListingView_Previews: PreviewProvider {
    static var previews: some View {
        ItemListingBadge(item: previewItemListings.first!)
    }
}
