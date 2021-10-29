//
//  ListingDetailView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 15/07/2021.
//

import CoreLocation
import FirebaseAuth
import FirebaseStorage
import GoogleSignIn
import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject var env: EnvironmentObjects

    // Other item details
    @State var itemImage = UIImage()
    @State var itemIsStarred = false
    @State var itemDistance: Double = 0
    @State var canGetLocation = false

    // Owner details
    @State var owner = previewUsers.first!
    @State var ownerProfileImage = UIImage(systemName: "person.circle.fill")!

    // Alert details
    @State var primaryAlertMessage = ""
    @State var secondaryAlertMessage = ""
    @State var showingAlert = false

    @State var showingChatButton = true

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    let deviceDimensions = UIScreen.main.bounds.size
    var item: ItemListing

    let l_star = NSLocalizedString("listingdetailview.star", comment: "Star")
    let l_unstar = NSLocalizedString("listingdetailview.unstar", comment: "Unstar")

    let l_starErrorAlertTitle = NSLocalizedString("listingdetailview.star_error_alert.title", comment: "Unable to star item")

    let l_unstarErrorAlertTitle = NSLocalizedString("listingdetailview.unstar_error_alert.title", comment: "Unable to unstar item")

    let l_fetchErrorAlertTitle = NSLocalizedString("editlistingview.fetch_error_alert.title", comment: "An error occurred while fetching this item's image")

    func starItem() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        guard var currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) else { return }
        currentUser.starredItems.append(item.id!)

        do {
            try env.userRepository.updateUser(user: currentUser)
            itemIsStarred = true
            print("Starred Item \(item.id!)")
        } catch {
            print("Could not star item \(item.id!): \(error.localizedDescription)")

            primaryAlertMessage = l_starErrorAlertTitle
            secondaryAlertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    func unstarItem() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        guard var currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) else { return }
        currentUser.starredItems.removeAll(where: { $0 == item.id })

        do {
            try env.userRepository.updateUser(user: currentUser)
            itemIsStarred = false
            print("Unstarred Item \(item.id!)")
        } catch {
            print("Could not unstar item \(item.id!): \(error.localizedDescription)")

            primaryAlertMessage = l_unstarErrorAlertTitle
            secondaryAlertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    var body: some View {
        VStack {
            Image(uiImage: runningForPreviews ? UIImage(named: "Preview \(item.name)")! : itemImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: deviceDimensions.height / 3)
                .alert(isPresented: $showingAlert) {
                    Alert(
                        title: Text(primaryAlertMessage),
                        message: Text(secondaryAlertMessage),
                        dismissButton: .default(Text("alert_dismiss", comment: "OK"))
                    )
                }
                .accessibility(hidden: true)

            VStack(spacing: 10) {
                Text(item.name)
                    .font(.largeTitle)
                    .accessibility(label: Text("listingdetailview_acc.item_name \(item.name)", comment: "Name: name"))

                Text(item.description)
                    .font(.subheadline)
                    .lineLimit(3)
                    .accessibility(label: Text("listingdetailview_acc.item_description \(item.description)", comment: "Description: description"))

                if canGetLocation {
                    let distanceString = itemDistance > 1000 ? "\(Int(round(itemDistance / 1000))) Km" : "\(Int(itemDistance)) m"

                    Text(distanceString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibility(label: Text("listingdetailview_acc.distance \(distanceString)", comment: "This item is distance away from your current location"))
                } else {
                    Text("listingdetailview.location_error", comment: "Unable to access location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibility(label: Text("listingdetailview_acc.location_error", comment: "Could not determine how far away this item is from your current location"))
                }
            }
            .multilineTextAlignment(.center)

            if env.authenticated {
                HStack(spacing: 18) {
                    if showingChatButton {
                        // Chat Button
                        NavigationLink(destination: ChatView(recipient: owner)) {
                            Label(
                                title: {
                                    Text("listingdetailview.chat", comment: "Chat")
                                        .fontWeight(.semibold)
                                },
                                icon: {
                                    Image(systemName: "message.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30)
                                }
                            )
                        }
                        .padding()
                        .frame(width: deviceDimensions.width / 2.5)
                        .background(Color.accentColor)
                        .cornerRadius(15)
                    }

                    // Star Button
                    Button(action: itemIsStarred ? unstarItem : starItem) {
                        Label(
                            title: {
                                Text(itemIsStarred ? l_unstar : l_star)
                                    .fontWeight(.semibold)
                            },
                            icon: {
                                Image(systemName: "star.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                            }
                        )
                    }
                    .padding()
                    .frame(width: deviceDimensions.width / 2.5)
                    .background(Color.yellow)
                    .cornerRadius(15)
                }
                .foregroundColor(.white)
                .padding(.top)
            } else {
                Text("listingdetailview.sign_in_msg", comment: "Sign in to star this item or chat with the owner")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }

            Spacer()

            VStack {
                Text("listingdetailview.item_by", comment: "Item By")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                // Owner details
                HStack {
                    let size = CGSize(width: 40, height: 40)
                    let placeholderImage = ProfileImage(image: Image(systemName: "person.circle.fill"), imageSize: size)

                    if let profileImageURL = owner.profileImageURL {
                        AsyncImage(url: URL(string: profileImageURL)) { image in
                            ProfileImage(image: image, imageSize: size)
                        } placeholder: {
                            placeholderImage
                        }
                    } else {
                        placeholderImage
                    }

                    Text(owner.fullName())
                        .font(.headline)
                }
            }
            .accessibilityElement(children: .combine)
            .accessibility(label: Text("listingdetailview_acc.item_by \(owner.fullName())", comment: "This item has been provided by owner"))
        }
        .navigationBarTitle(Text("listingdetailview.nav_title", comment: "Item Listing Details"), displayMode: .inline)
        .onAppear {
            guard !runningForPreviews else { return }

            if let currentUID = Auth.auth().currentUser?.uid {
                // Don't show chat button if user is viewing their own item
                showingChatButton = currentUID != item.ownerID

                if let currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) {
                    // Determine if the item has been starred by the current user or not
                    itemIsStarred = currentUser.starredItems.contains(item.id!)
                }
            }

            // Get item owner
            if let itemOwner = env.userRepository.users.first(where: { $0.uid == item.ownerID }) {
                self.owner = itemOwner
            }

            // Get item's distance from current position
            let geoPoint = item.location
            let itemLocation = CLLocation(latitude: geoPoint.latitude, longitude: geoPoint.longitude)

            // Check location authorization
            let locationManager = CLLocationManager()
            let locationAuthorization = locationManager.authorizationStatus
            canGetLocation = (locationAuthorization == .authorizedAlways || locationAuthorization == .authorizedWhenInUse)

            if canGetLocation {
                if let currentLocation = locationManager.location {
                    itemDistance = currentLocation.distance(from: itemLocation)
                }
            }

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
                        print("Could not fetch item listing image: \(error.localizedDescription)")

                        primaryAlertMessage = l_fetchErrorAlertTitle
                        secondaryAlertMessage = error.localizedDescription
                        showingAlert = true

                        return
                    }

                    if let data = data {
                        if let image = UIImage(data: data) {
                            env.listingImageCache[item.id!] = image // Save to local cache
                            itemImage = image
                        }
                    }
                }
            }
        }
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(item: previewItemListings.first!)
    }
}
