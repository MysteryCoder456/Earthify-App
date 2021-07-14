//
//  ListingDetailView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 15/07/2021.
//

import SwiftUI
import FirebaseStorage

struct ListingDetailView: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var itemImage = UIImage()
    
    // Alert details
    @State var primaryAlertMessage = ""
    @State var secondaryAlertMessage = ""
    @State var showingAlert = false
    
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    let deviceDimensions = UIScreen.main.bounds.size
    var item: ItemListing
    
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
        }
        .navigationBarTitle("Item Listing Details", displayMode: .inline)
        .onAppear() {
            let storageRef = Storage.storage().reference(withPath: "listingImages/\(item.id!).jpg")
            let sizeLimit = env.listingImageMaximumSize
            
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
        }
    }
}

struct ListingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListingDetailView(item: previewItemListings.first!)
            
    }
}
