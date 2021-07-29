//
//  EditListingView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 26/07/2021.
//

import FirebaseAuth
import FirebaseStorage
import SwiftUI

enum ActiveAlert {
    case regular
    case deletion
}

struct EditListingView: View {
    @EnvironmentObject var env: EnvironmentObjects
    @Environment(\.presentationMode) var presentationMode

    // Image Picker details
    @State var showingImagePicker = false
    @State var showingImageSourceSelector = false
    @State var imageSource: UIImagePickerController.SourceType?

    // Alert details
    @State var primaryAlertMessage = ""
    @State var secondaryAlertMessage = ""
    @State var showingAlert = false
    @State var activeAlert = ActiveAlert.regular

    // Item details
    @State var itemImage = UIImage()
    @State var item: ItemListing

    let maxImageSize = CGSize(width: 250, height: 172)
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    func deleteItemListing() {
        let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")

        storageRef.delete { error in
            if let error = error {
                print("Could not delete item listing image: \(error.localizedDescription)")

                primaryAlertMessage = "Unable to delete item listing image"
                secondaryAlertMessage = error.localizedDescription
                activeAlert = .regular
                showingAlert = true

                return
            }

            // Delete listing from Firestore if image was successfully deleted
            env.listingRepository.deleteListing(listing: item)
            print("Item listing \(item.id!) was successfully deleted!")

            // Dismiss the current view
            presentationMode.wrappedValue.dismiss()
        }
    }

    func updateItemListing() {
        if let currentUID = Auth.auth().currentUser?.uid {
            // Ensure that the current user is the
            // owner of the item being updated
            guard currentUID == item.ownerID else { return }

            // Remove extra whitespace and new lines
            item.name = item.name.trimmingCharacters(in: .whitespacesAndNewlines)
            item.description = item.description.trimmingCharacters(in: .whitespacesAndNewlines)

            // Check if all content fields are filled
            guard !item.name.isEmpty,
                  !item.description.isEmpty,
                  itemImage.size != CGSize.zero else { return }

            // Upload image to Firebase Storage
            let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")

            guard let imageData = itemImage.jpegData(compressionQuality: 0.3) else { return }

            let sizeLimit = env.listingImageMaximumSize
            let sizeLimitMB = sizeLimit / 1_048_576

            // Check if the image is within the size limit
            if imageData.count > sizeLimit {
                print("Could not upload item listing image: Image is more than \(sizeLimitMB) MB")

                primaryAlertMessage = "Unable to upload image"
                secondaryAlertMessage = "Image must be smaller than \(sizeLimitMB) MB"
                activeAlert = .regular
                showingAlert = true

                return
            }

            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"

            storageRef.putData(imageData, metadata: uploadMetadata) { _, error in
                activeAlert = .regular

                if let error = error {
                    print("Could not upload item listing image: \(error.localizedDescription)")

                    primaryAlertMessage = "Unable to upload image"
                    secondaryAlertMessage = error.localizedDescription
                    showingAlert = true

                    return
                }

                print("Item listing image uploaded successfully")

                // Update listing in Firestore if image upload was successful
                do {
                    try env.listingRepository.updateListing(listing: item)
                    print("Listing \(item.id!) updated successfully")

                    primaryAlertMessage = "Item Updated Successfully"
                    secondaryAlertMessage = "Check it out in the Item Browser!"
                    showingAlert = true
                } catch {
                    print("Could not update listing \(item.id!): \(error.localizedDescription)")

                    primaryAlertMessage = "Unable to update listing"
                    secondaryAlertMessage = error.localizedDescription
                    showingAlert = true

                    // Delete item image if listing was not updated successfully
                    storageRef.delete { error in
                        if let error = error {
                            print("Could not delete item listing image: \(error.localizedDescription)")
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
                            .cancel { print("Cancelled source selection") },
                            .default(Text("Camera")) { imageSource = .camera; showingImagePicker = true },
                            .default(Text("Photo Library")) { imageSource = .photoLibrary; showingImagePicker = true },
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

                TextField("Title", text: $item.name)
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

                TextField("Description", text: $item.description)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
            }
            .padding()

            // Update Button
            Button(action: updateItemListing) {
                Label(
                    title: {
                        Text("Update Listing")
                            .font(.title2)
                            .fontWeight(.semibold)
                    },
                    icon: {
                        Image(systemName: "square.and.pencil")
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
        }
        .navigationBarTitle("Update Listing")
        .sheet(isPresented: $showingImagePicker) {
            if let source = imageSource {
                ImagePickerView(sourceType: source) { image in
                    itemImage = image
                }
            }
        }
        .alert(isPresented: $showingAlert) {
            let alert: Alert

            switch activeAlert {
            case .regular:
                alert = Alert(
                    title: Text(primaryAlertMessage),
                    message: Text(secondaryAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            case .deletion:
                alert = Alert(
                    title: Text("Are you sure you want to delete this listing?"),
                    message: Text("This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete"), action: deleteItemListing),
                    secondaryButton: .default(Text("Cancel"))
                )
            }

            return alert
        }
        .onAppear {
            guard !runningForPreviews else {
                itemImage = UIImage(named: "Preview \(item.name)")!
                return
            }

            let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")
            let sizeLimit = env.listingImageMaximumSize

            storageRef.getData(maxSize: sizeLimit) { data, error in
                if let error = error {
                    print("Could not fetch item listing image for \(item.id!): \(error.localizedDescription)")

                    primaryAlertMessage = "An error occured while fetching this item's image"
                    secondaryAlertMessage = error.localizedDescription
                    showingAlert = true

                    return
                }

                if let data = data {
                    if let image = UIImage(data: data) {
                        itemImage = image
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(action: {
                    activeAlert = .deletion
                    showingAlert = true
                }) {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

struct EditListingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditListingView(item: previewItemListings.first!)
        }
    }
}
