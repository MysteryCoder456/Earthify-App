//
//  ProfileImage.swift
//  ProfileImage
//
//  Created by Rehatbir Singh on 15/08/2021.
//

import SwiftUI

struct ProfileImage: View {
    let image: Image
    let imageSize: CGSize

    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(width: imageSize.width, height: imageSize.height)
            .clipped()
            .clipShape(Circle())
    }
}
