//
//  ChatRow.swift
//  Earthify
//
//  Created by Rehatbir Singh on 29/07/2021.
//

import SwiftUI

struct ProfileImage: View {
    let image: Image
    let imageSize = CGSize(width: 60, height: 60)

    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: imageSize.width, height: imageSize.height)
            .clipped()
            .clipShape(Circle())
    }
}

struct ChatRow: View {
    let user: AppUser
    let placeholderImage = ProfileImage(image: Image(systemName: "person.circle.fill"))

    var body: some View {
        HStack {
            if let profileImageURL = user.profileImageURL {
                AsyncImage(url: URL(string: profileImageURL)) { image in
                    ProfileImage(image: image)
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
    }
}

struct ChatRow_Previews: PreviewProvider {
    static var previews: some View {
        List(previewUsers, id: \.uid) { user in
            ChatRow(user: user)
        }
    }
}
