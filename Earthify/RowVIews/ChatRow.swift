//
//  ChatRow.swift
//  Earthify
//
//  Created by Rehatbir Singh on 29/07/2021.
//

import SwiftUI

struct ChatRow: View {
    let user: AppUser
    let placeholderImage = ProfileImage(image: Image(systemName: "person.circle.fill"), imageSize: CGSize(width: 60, height: 60))

    var body: some View {
        HStack {
            if let profileImageURL = user.profileImageURL {
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    ProfileImage(image: image, imageSize: CGSize(width: 60, height: 60))
                } placeholder: {
                    placeholderImage
                }
            } else {
                placeholderImage
            }

            Text(user.fullName())
                .font(.title3)
                .fontWeight(.medium)
                .padding(.horizontal, 6)
                .lineLimit(1)
        }
        .padding(.vertical)
        .accessibilityElement(children: .combine)
        .accessibility(label: Text("chatrow_acc.chat_with \(user.fullName())", comment: "Chat with user"))
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewUsers, id: \.uid) { user in
            ChatRow(user: user)
        }
    }
}
