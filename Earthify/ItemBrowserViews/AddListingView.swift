//
//  AddListingView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 13/07/2021.
//

import CoreLocation
import Firebase
import SwiftUI

struct AddListingView: View {
    @EnvironmentObject var env: EnvironmentObjects

    // Image Picker details
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
    
    let l_titleFieldHint = NSLocalizedString("addlistingview.title_field.hint", comment: "Title")
    let l_descriptionFieldHint = NSLocalizedString("addlistingview.description_field.hint", comment: "Description")
    
    let l_locationAlertTitle = NSLocalizedString("addlistingview.location_alert.title", comment: "Please enable Location Services for Earthify")
    let l_locationAlertMsg = NSLocalizedString("addlistingview.location_alert.msg", comment: "Earthify requires your location to show people items that are closer to them.")
    
    let l_locationErrorAlertTitle = NSLocalizedString("addlistingview.location_error_alert.title", comment: "Unable to get current location")
    let l_locationErrorAlertMsg = NSLocalizedString("addlistingview.location_error_alert.msg", comment: "Something went wrong while getting your current location.")
    
    let l_uploadErrorAlertTitle = NSLocalizedString("addlistingview.upload_error_alert.title", comment: "Unable to upload image")
    
    let l_addSuccessAlertTitle = NSLocalizedString("addlistingview.add_success_alert.title", comment: "Item Added Successfully")
    let l_addSuccessAlertMsg = NSLocalizedString("addlistingview.add_success_alert.msg", comment: "Check it out in the Item Browser!")
    
    let l_addFailureAlertTitle = NSLocalizedString("addlistingview.add_failure_alert.title", comment: "Unable to add a new listing")

    func addItemListing() {
        if let currentUID = Auth.auth().currentUser?.uid {
            // Remove extra whitespace and new lines
            itemName = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
            itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)

            // Check if all content fields are filled
            guard !itemName.isEmpty,
                  !itemDescription.isEmpty,
                  itemImage.size != CGSize.zero else { return }

            // Check location authorization
            let locationManager = CLLocationManager()
            let locationAuthorization = locationManager.authorizationStatus
            let canGetLocation = (locationAuthorization == .authorizedAlways || locationAuthorization == .authorizedWhenInUse)

            guard canGetLocation else {
                primaryAlertMessage = l_locationAlertTitle
                secondaryAlertMessage = l_locationAlertMsg
                showingAlert = true

                return
            }

            // Get current location
            guard let currentCoordinates = locationManager.location?.coordinate else {
                primaryAlertMessage = l_locationErrorAlertTitle
                secondaryAlertMessage = l_locationErrorAlertMsg
                showingAlert = true

                return
            }
            let newItemListing = ItemListing(name: itemName, description: itemDescription, ownerID: currentUID, location: GeoPoint(latitude: currentCoordinates.latitude, longitude: currentCoordinates.longitude))

            // Upload image to Firebase Storage
            let storageRef = Storage.storage().reference(withPath: "listingImages/\(newItemListing.id!).jpg")

            guard let imageData = itemImage.jpegData(compressionQuality: 0.3) else { return }

            let sizeLimit = env.listingImageMaximumSize
            let sizeLimitMB = sizeLimit / 1_048_576

            // Check if the image is within the size limit
            if imageData.count > sizeLimit {
                print("Could not upload item listing image: Image is more than \(sizeLimitMB) MB")

                let l_msg = NSLocalizedString("addlistingview.image_size_alert.msg %lld", comment: "Image must be smaller than %lld MB")
                
                primaryAlertMessage = l_uploadErrorAlertTitle
                secondaryAlertMessage = String(format: l_msg, sizeLimitMB)
                showingAlert = true

                return
            }

            let uploadMetadata = StorageMetadata()
            uploadMetadata.contentType = "image/jpeg"

            storageRef.putData(imageData, metadata: uploadMetadata) { _, error in
                if let error = error {
                    print("Could not upload item listing image: \(error.localizedDescription)")

                    primaryAlertMessage = l_uploadErrorAlertTitle
                    secondaryAlertMessage = error.localizedDescription
                    showingAlert = true

                    return
                }

                print("Item listing image uploaded successfully")

                // Add listing to Firestore if image upload was successful
                do {
                    try env.listingRepository.updateListing(newItemListing)
                    print("Listing added to Firestore successfully")

                    // Reset content fields
                    itemImage = UIImage()
                    itemName = ""
                    itemDescription = ""

                    primaryAlertMessage = l_addSuccessAlertTitle
                    secondaryAlertMessage = l_addSuccessAlertMsg
                    showingAlert = true
                } catch {
                    print("Could not add new item listing: \(error.localizedDescription)")

                    primaryAlertMessage = l_addFailureAlertTitle
                    secondaryAlertMessage = error.localizedDescription
                    showingAlert = true

                    // Delete item image if listing was not added to Firestore
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

                TextField(l_titleFieldHint, text: $itemName)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
                    .accessibilityLabel(Text("addlistingview_acc.title_field", comment: "Enter a title for your listing"))
            }
            .padding()

            // Item Description
            VStack {
                Text("addlistingview.description_field.header", comment: "Enter a short description of your item:")
                    .font(.headline)
                    .accessibilityHidden(true)

                TextField(l_descriptionFieldHint, text: $itemDescription)
                    .padding(7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineWidth: 1.5)
                            .fill(Color.secondary)
                    )
                    .accessibilityLabel(Text("addlistingview_acc.description_field", comment: "Enter a short description of your item"))
            }
            .padding()

            // Add Item Button
            Button(action: addItemListing) {
                Label(
                    title: {
                        Text("addlistingview.add_btn", comment: "Add Listing")
                            .font(.title2)
                            .fontWeight(.semibold)
                    },
                    icon: {
                        Image(systemName: "plus.square")
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
                    dismissButton: .default(Text("alert_dismiss", comment: "OK"))
                )
            }
        }
        .navigationTitle(Text("addlistingview.nav_title", comment: "New Item Listing"))
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
        NavigationView {
            AddListingView()
        }
    }
}
