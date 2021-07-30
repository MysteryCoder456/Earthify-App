//
//  ChatsBrowser.swift
//  Earthify
//
//  Created by Rehatbir Singh on 29/07/2021.
//

import FirebaseAuth
import SwiftUI

struct ChatsBrowser: View {
    @EnvironmentObject var env: EnvironmentObjects
    @State var chats: [AppUser] = []
    
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    func fetchChats() {
        guard !runningForPreviews else {
            chats = previewUsers
            return
        }
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        chats = []
        let messages = env.messageRepository.messages
        var addedUsers: [String] = []
        
        for message in messages {
            let receiverID = message.recipients[0] == currentUID ? message.recipients[1] : message.recipients[0]
            if !addedUsers.contains(receiverID) {
                guard let user = env.userRepository.users.first(where: { $0.uid == receiverID }) else { return }
                addedUsers.append(receiverID)
                chats.append(user)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if chats.isEmpty {
                    List {
                        Text("You don't have any chats yet.\nStart a conversation from an item's page")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .refreshable(action: fetchChats)
                } else {
                    List(chats, id: \.uid) { user in
                        NavigationLink(destination: ChatView(user: user)) {
                            ChatRow(user: user)
                        }
                    }
                    .refreshable(action: fetchChats)
                }
            }
            .navigationTitle("Search Chats")
        }
        .onAppear(perform: fetchChats)
    }
}

struct ChatsBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ChatsBrowser()
    }
}
