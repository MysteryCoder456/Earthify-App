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

            primaryAlertMessage = "Unable to star item"
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

            primaryAlertMessage = "Unable to unstar item"
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
                        dismissButton: .default(Text("OK"))
                    )
                }
                .accessibility(hidden: true)

            VStack(spacing: 10) {
                Text(item.name)
                    .font(.largeTitle)
                    .accessibility(label: Text("Name: \(item.name)"))

                Text(item.description)
                    .font(.subheadline)
                    .lineLimit(3)
                    .accessibility(label: Text("Description: \(item.description)"))
                
                if canGetLocation {
                    let distanceString = itemDistance > 1000 ? "\(Int(round(itemDistance / 1000))) Km" : "\(Int(itemDistance)) m"
                    
                    Text(distanceString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibility(label: Text("This item is \(distanceString) away from your current location"))
                } else {
                    Text("Unable to access location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibility(label: Text("Could not determine how far away this item is from your current location"))
                }
            }
            .multilineTextAlignment(.center)

            // FIXME: ChatView closes after sending a message when opening from here
            if env.authenticated {
                HStack(spacing: 18) {
                    if showingChatButton {
                        // Chat Button
                        NavigationLink(destination: ChatView(recipient: owner)) {
                            Label(
                                title: {
                                    Text("Chat")
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
                                Text(itemIsStarred ? "Unstar" : "Star")
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
                Text("Sign in to star this item or chat with the owner")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top)
            }

            Spacer()

            VStack {
                Text("Item By")
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
            .accessibility(label: Text("This item has been provided by \(owner.fullName())"))
        }
        .navigationBarTitle("Item Listing Details", displayMode: .inline)
        .onAppear {
            guard !runningForPreviews else { return }

            // Determine if the item has been starred by the current user or not
            if let currentUID = Auth.auth().currentUser?.uid {
                // Don't show chat button if user is viewing their own item
                showingChatButton = currentUID != item.ownerID

                if let currentUser = env.userRepository.users.first(where: { $0.uid == currentUID }) {
                    itemIsStarred = currentUser.starredItems.contains(item.id!)
                }
            }

            let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")
            let sizeLimit = env.listingImageMaximumSize

            // Fetch item image
            storageRef.getData(maxSize: sizeLimit) { data, error in
                if let error = error {
                    print("Could not fetch item listing image: \(error.localizedDescription)")

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
        }
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(item: previewItemListings.first!)
    }
}
