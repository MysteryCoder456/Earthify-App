//
//  EditListingView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 26/07/2021.
//

import FirebaseAuth
import FirebaseStorage
import SwiftUI

private enum ActiveAlert {
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
    @State private var activeAlert = ActiveAlert.regular

    // Item details
    @State var itemImage = UIImage()
    @State var item: ItemListing

    let maxImageSize = CGSize(width: 250, height: 172)
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    let l_titleFieldHint = NSLocalizedString("addlistingview.title_field.hint", comment: "Title")
    let l_descriptionFieldHint = NSLocalizedString("addlistingview.description_field.hint", comment: "Description")
    let l_deleteListing = NSLocalizedString("editlistingview.delete_listing", comment: "Delete Listing")

    let l_deleteFailureAlertTitle = NSLocalizedString("editlistingview.delete_failure_alert.title", comment: "Unable to delete item listing image")

    let l_uploadErrorAlertTitle = NSLocalizedString("addlistingview.upload_error_alert.title", comment: "Unable to upload image")

    let l_updateSuccessAlertTitle = NSLocalizedString("editlistingview.update_success_alert.title", comment: "Item Updated Successfully")
    let l_updateSuccessAlertMsg = NSLocalizedString("addlistingview.add_success_alert.msg", comment: "Check it out in the Item Browser!")

    let l_updateFailureAlertTitle = NSLocalizedString("editlistingview.update_failure_alert.title", comment: "Unable to update listing")

    let l_fetchErrorAlertTitle = NSLocalizedString("editlistingview.fetch_error_alert.title", comment: "An error occurred while fetching this item's image")

    func deleteItemListing() {
        let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")

        storageRef.delete { error in
            if let error = error {
                print("Could not delete item listing image: \(error.localizedDescription)")

                primaryAlertMessage = l_deleteFailureAlertTitle
                secondaryAlertMessage = error.localizedDescription
                activeAlert = .regular
                showingAlert = true

                return
            }

            // Delete listing from Firestore if image was successfully deleted
            env.listingRepository.deleteListing(item)
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

                let l_msg = NSLocalizedString("addlistingview.image_size_alert.msg %lld", comment: "Image must be smaller than %lld MB")

                primaryAlertMessage = l_uploadErrorAlertTitle
                secondaryAlertMessage = String(format: l_msg, sizeLimitMB)
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

                    primaryAlertMessage = l_uploadErrorAlertTitle
                    secondaryAlertMessage = error.localizedDescription
                    showingAlert = true

                    return
                }

                print("Item listing image uploaded successfully")

                // Update listing in Firestore if image upload was successful
                do {
                    try env.listingRepository.updateListing(item)
                    print("Listing \(item.id!) updated successfully")

                    primaryAlertMessage = l_updateSuccessAlertTitle
                    secondaryAlertMessage = l_updateSuccessAlertMsg
                    showingAlert = true
                } catch {
                    print("Could not update listing \(item.id!): \(error.localizedDescription)")

                    primaryAlertMessage = l_updateFailureAlertTitle
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
                Text("addlistingview.image_picker.title", comment: "Click a picture of your item:")
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
                .background(Color.secondary)
                .cornerRadius(30)
                .actionSheet(isPresented: $showingImageSourceSelector) {
                    ActionSheet(
                        title: Text("addlistingview.source_selector_msg", comment: "Select Image Source"),
                        buttons: [
                            .cancel { print("Cancelled source selection") },
                            .default(Text("addlistingview.camera", comment: "Camera")) { imageSource = .camera; showingImagePicker = true },
                            .default(Text("addlistingview.photo_library", comment: "Photo Library")) { imageSource = .photoLibrary; showingImagePicker = true },
                        ]
                    )
                }

                Text("addlistingview.image_picker.subtitle", comment: "Make sure that your item is clearly visible in the picture")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(Text("addlistingview_acc.image_picker.hint", comment: "Opens a dialogue to choose image source"))

            // Item Name
            VStack {
                Text("addlistingview.title_field.header", comment: "Enter a title for your listing:")
                    .font(.headline)
                    .accessibilityHidden(true)

                TextField(l_titleFieldHint, text: $item.name)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
                    .accessibilityLabel(Text("addlistingview_acc.title_field", comment: "Enter a title for your listing"))
                    .accessibilityValue(Text("editlistingview_acc.title_field.current_value \(item.name)", comment: "Current title: title"))
            }
            .padding()

            // Item Description
            VStack {
                Text("addlistingview.description_field.header", comment: "Enter a short description of your item:")
                    .font(.headline)
                    .accessibilityHidden(true)

                TextField(l_descriptionFieldHint, text: $item.description)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
                    .accessibilityLabel(Text("addlistingview_acc.description_field", comment: "Enter a short description of your item"))
                    .accessibilityValue(Text("editlistingview_acc.description_field.current_value \(item.description)", comment: "Current description: description"))
            }
            .padding()

            // Update Button
            Button(action: updateItemListing) {
                Label(
                    title: {
                        Text("editlistingview.update_btn", comment: "Update Listing")
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
        .navigationBarTitle(Text("editlistingview.nav_title", comment: "Update Listing"), displayMode: .inline)
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
                    dismissButton: .default(Text("alert_dismiss", comment: "OK"))
                )
            case .deletion:
                alert = Alert(
                    title: Text("editlistingview.deletion_alert.title", comment: "Are you sure you want to delete this listing?"),
                    message: Text("editlistingview.deletion_alert.msg", comment: "This action cannot be undone."),
                    primaryButton: .destructive(Text("editlistingview.deletion_alert.delete", comment: "Delete"), action: deleteItemListing),
                    secondaryButton: .default(Text("alert_cancel", comment: "Cancel"))
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

                    primaryAlertMessage = l_fetchErrorAlertTitle
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
                    Label(l_deleteListing, systemImage: "trash")
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
