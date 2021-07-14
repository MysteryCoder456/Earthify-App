//
//  AddListingView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 13/07/2021.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct AddListingView: View {
    @EnvironmentObject var env: EnvironmentObjects
    
    @State var showingImagePicker = false
    @State var showingImageSourceSelector = false
    @State var imageSource: UIImagePickerController.SourceType?
    
    // Alert details
    @State var primaryAlertMessage = ""
    @State var secondaryAlertMessage = ""
    @State var showingAlert = false
    
    // New Item's Details
    @State var itemImage = UIImage()
    @State var itemName = ""
    @State var itemDescription = ""
    
    let maxImageSize = CGSize(width: 250, height: 172)
    
    func addItemListing() {
        if let currentUID = Auth.auth().currentUser?.uid {
            // Remove extra whitespace and new lines
            itemName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if all content fields are filled
            if !itemName.isEmpty && !itemDescription.isEmpty && itemImage.size != CGSize.zero {
                
                let newItemListing = ItemListing(id: UUID().uuidString, name: itemName, description: itemDescription, ownerID: currentUID)
                
                // Upload image to Firebase Storage
                let storageRef = Storage.storage().reference(withPath: "listingImages/\(newItemListing.id!).jpg")
                
                guard let imageData = itemImage.jpegData(compressionQuality: 0.5) else { return }
                
                let sizeLimit = env.listingImageMaximumSize
                let sizeLimitMB = sizeLimit / 1048576
                
                // Check if the image is within the size limit
                if imageData.count > sizeLimit {
                    print("Could not upload item listing image: Image is more than \(sizeLimitMB) MB")
                    
                    primaryAlertMessage = "Unable to upload image"
                    secondaryAlertMessage = "Image must be smaller than \(sizeLimitMB) MB"
                    showingAlert = true
                    
                    return
                }
                
                let uploadMetadata = StorageMetadata()
                uploadMetadata.contentType = "image/jpeg"
                
                storageRef.putData(imageData, metadata: uploadMetadata) { downloadMetadata, error in
                    if let error = error {
                        print("Could not upload item listing image: \(error.localizedDescription)")
                        
                        primaryAlertMessage = "Unable to upload image"
                        secondaryAlertMessage = error.localizedDescription
                        showingAlert = true
                        
                        return
                    }
                    
                    print("Item listing image uploaded successfully")
                    
                    // Add listing to Firestore if image upload was successful
                    do {
                        try env.listingRepository.updateListing(listing: newItemListing)
                        print("Listing added to Firestore successfully")
                        
                        // Reset content fields
                        itemImage = UIImage()
                        itemName = ""
                        itemDescription = ""
                        
                        primaryAlertMessage = "Item Added Successfully"
                        secondaryAlertMessage = "Check it out in the Item Browser!"
                        showingAlert = true
                    } catch {
                        print("Could not add new item listing: \(error.localizedDescription)")
                        
                        primaryAlertMessage = "Unable to add a new listing"
                        secondaryAlertMessage = error.localizedDescription
                        showingAlert = true
                        
                        // Delete item image if listing was not added to Firestore
                        storageRef.delete() { error in
                            if let error = error {
                                print("Could not delete item listing image: \(error.localizedDescription)")
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // Image Picker
            VStack {
                Text("Click a picture of your item:")
                    .font(.headline)
                
                Button(action: { showingImageSourceSelector = true }) {
                    if itemImage.size == CGSize.zero {
                        Image(systemName: "camera")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding(50)
                            .foregroundColor(.white)
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
                
                Text("Make sure that your item is clearly visible in the picture")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Item Name
            VStack {
                Text("Enter a title for your listing:")
                    .font(.headline)
                
                TextField("Title", text: $itemName)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
            }
            .padding()
            
            // Item Description
            VStack {
                Text("Enter a short description of your item:")
                    .font(.headline)
                
                TextField("Description", text: $itemDescription)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
            }
            .padding()
            
            // Add Item Button
            Button(action: addItemListing) {
                Label(
                    title: {
                        Text("Add Listing")
                            .font(.title2)
                            .fontWeight(.semibold)
                    },
                    icon: {
                        Image(systemName: "archivebox")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30)
                    }
                )
                .padding(.horizontal, 30)
            }
            .padding(.vertical)
            .foregroundColor(.white)
            .background(Color.accentColor)
            .cornerRadius(12)
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(primaryAlertMessage),
                    message: Text(secondaryAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
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
