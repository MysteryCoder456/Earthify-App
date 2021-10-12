//
//  ChatBubble.swift
//  Earthify
//
//  Created by Rehatbir Singh on 30/07/2021.
//

import SwiftUI

enum MessagePosition {
    case primary
    case secondary
}

struct BubbleShape: Shape {
    let position: MessagePosition

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight, position == .primary ? .bottomLeft : .bottomRight], cornerRadii: CGSize(width: 15, height: 15))

        return Path(path.cgPath)
    }
}

struct ChatBubble: View {
    let content: String
    let author: String
    let position: MessagePosition

    var body: some View {
        HStack {
            if position == .primary {
                Spacer()
            }

            VStack(alignment: position == .primary ? .trailing : .leading) {
                Text(content)
                    .padding()
                    .foregroundColor(.white)
                    .background(position == .primary ? Color.accentColor : Color.secondary)
                    .clipShape(BubbleShape(position: position))

                Text(author)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(position == .primary ? .trailing : .leading)

            if position == .secondary {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(author) says: \(content)"))
    }
}
