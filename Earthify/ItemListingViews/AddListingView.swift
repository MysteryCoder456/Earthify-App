//
//  AddListingView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 13/07/2021.
//

import SwiftUI

struct AddListingView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State var showingImagePicker = false
    @State var showingImageSourceSelector = false
    
    @State var imageSource: UIImagePickerController.SourceType?
    @State var itemImage = UIImage()
    
    let maxImageSize = CGSize(width: 320, height: 220)
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    Button(action: { showingImageSourceSelector = true }) {
                        if itemImage.size == CGSize.zero {
                            Image(systemName: "camera")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .padding(75)
                                .foregroundColor(colorScheme == .dark ? .black : .white)
                        } else {
                            Image(uiImage: itemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: maxImageSize.width, maxHeight: maxImageSize.height)
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: maxImageSize.width, maxHeight: maxImageSize.height)
                    .background(Color(.sRGB, red: 0.2, green: 0.8, blue: 0.2, opacity: 1.0))
                    .cornerRadius(30)
                    .actionSheet(isPresented: $showingImageSourceSelector) {
                        ActionSheet(
                            title: Text("Select Image Source"),
                            buttons: [
                                .cancel() { print("Cancelled source selection") },
                                .default(Text("Camera")) { imageSource = .camera; showingImagePicker = true },
                                .default(Text("Photo Library")) { imageSource = .photoLibrary; showingImagePicker = true }
                            ]
                        )
                    }
                    
                    Text("Take a picture of your item. Make sure that it is clearly visible.")
                        .multilineTextAlignment(.center)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("New Item Listing")
        .sheet(isPresented: $showingImagePicker) {
            if let source = imageSource {
                ImagePickerView(sourceType: source) { image in
                    itemImage = image
                }
            }
        }
    }
}

struct AddListingView_Previews: PreviewProvider {
    static var previews: some View {
        AddListingView()
    }
}
