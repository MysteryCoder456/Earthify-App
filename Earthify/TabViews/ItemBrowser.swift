//
//  ItemBrowser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 11/07/2021.
//

import SwiftUI

struct SearchBar: View {
    let label: String
    @Binding var text: String

    @State var isEditing = false

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "text.magnifyingglass")
                    .padding(.leading, 10)
                    .foregroundColor(.secondary)

                TextField(label, text: $text)
                    .padding(.vertical, 7)
                    .onTapGesture {
                        isEditing = true
                    }

                Button(action: { $text.wrappedValue = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .padding(.trailing, 10)
                        .foregroundColor(.secondary)
                }
            }
            .background(Color.secondary.opacity(0.4))
            .cornerRadius(8)
            .animation(.easeInOut)

            if isEditing {
                Button("Cancel") {
                    self.isEditing = false
                    self.text = ""

                    // Dismiss keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .padding(.horizontal, 3)
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
        .padding(10)
    }
}

struct ItemBrowser: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var searchText = ""

    let columns = [
        GridItem(.adaptive(minimum: 150)),
    ]

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    var body: some View {
        NavigationView {
            ScrollView {
                SearchBar(label: "Search for items...", text: $searchText)

                LazyVGrid(columns: columns, spacing: 25) {
                    let listings = runningForPreviews ? previewItemListings : env.listingRepository.itemListings

                    ForEach(listings.filter { searchText.isEmpty || $0.name.lowercased().contains(searchText.lowercased()) || $0.description.lowercased().contains(searchText.lowercased()) }, id: \.self) { listing in
                        ItemListingBadge(item: listing)
                    }
                    .navigationTitle("Search Earthify")
                }
            }
        }
    }
}

struct ItemBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ItemBrowser()
            .environmentObject(EnvironmentObjects())
    }
}
