//
//  SearchBar.swift
//  Earthify
//
//  Created by Rehatbir Singh on 13/07/2021.
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
            .animation(.default)

            if isEditing {
                Button("Cancel") {
                    isEditing = false
                    text = ""

                    // Dismiss keyboard
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .transition(.move(edge: .trailing))
                .animation(.default)
            }
        }
    }
}
