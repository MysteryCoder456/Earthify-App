//
//  ListingDetailView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 15/07/2021.
//

import FirebaseStorage
import GoogleSignIn
import SwiftUI

struct ListingDetailView: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var itemImage = UIImage()
    
    // Owner details
    @State var owner = previewUsers.first!
    @State var ownerProfileImage = UIImage(systemName: "person.circle.fill")!

    // Alert details
    @State var primaryAlertMessage = ""
    @State var secondaryAlertMessage = ""
    @State var showingAlert = false

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    let deviceDimensions = UIScreen.main.bounds.size
    var item: ItemListing
    
    func cropToSquare(_ image: UIImage) -> UIImage {
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let cropSize = min(imageWidth, imageHeight)
        let cropRect: CGRect
        
        if imageWidth > imageHeight {
            cropRect = CGRect(
                x: (imageWidth - cropSize) / 2,
                y: 0,
                width: cropSize,
                height: cropSize
            )
        } else {
            cropRect = CGRect(
                x: 0,
                y: (imageHeight - cropSize) / 2,
                width: cropSize,
                height: cropSize
            )
        }
        
        let cgImage = image.cgImage!
        let croppedCGImage = cgImage.cropping(to: cropRect)!
        
        return UIImage(cgImage: croppedCGImage)
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

            VStack(spacing: 10) {
                Text(item.name)
                    .font(.largeTitle)

                Text(item.description)
                    .font(.subheadline)
                    .lineLimit(3)
            }
            .multilineTextAlignment(.center)

            HStack(spacing: 18) {
                // Chat Button
                Button(action: {}) {
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

                // Star Button
                Button(action: {}) {
                    Label(
                        title: {
                            Text("Star")
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
                .background(Color(.sRGB, red: 0.93, green: 0.78, blue: 0.07, opacity: 1.0))
                .cornerRadius(15)
            }
            .foregroundColor(.white)
            .padding(.top)

            Spacer()
            
            Text("Item By")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            // Owner details
            HStack {
                let size: CGFloat = 40
                let ownerFullname = "\(owner.firstName) \(owner.lastName)"
                
                Image(uiImage: ownerProfileImage)
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
                
                Text(ownerFullname)
                    .font(.headline)
            }
        }
        .navigationBarTitle("Item Listing Details", displayMode: .inline)
        .onAppear {
            guard !runningForPreviews else { return }
            
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
            
            // Fetch owner's profile image
            guard let itemOwner = env.userRepository.users.first(where: { $0.uid == item.ownerID }) else { return }
            self.owner = itemOwner
            
            if let profileImageURLString = owner.profileImageURL {
                let profileImageURL = URL(string: profileImageURLString)!
                
                // Asynchronously fetch the owner's profile picture from Google Profile
                let task = URLSession.shared.dataTask(with: profileImageURL) { data, response, error in
                    // Print the HTTP response if it exists
                    if let response = response {
                        print(response)
                    }
                    
                    if let error = error {
                        print("Could not fetch item owner's profile image: \(error.localizedDescription)")
                        
                        primaryAlertMessage = "An error occured while fetching this item owner's profile picture"
                        secondaryAlertMessage = error.localizedDescription
                        showingAlert = true
                        
                        return
                    }
                    
                    if let data = data {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: data) {
                                let croppedImage = cropToSquare(image)
                                ownerProfileImage = croppedImage
                            }
                        }
                    }
                }
                
                // Run the asynchronous task
                task.resume()
            }
        }
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(item: previewItemListings.first!)
    }
}