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
    @State var searchText = ""

    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    let l_signInMsg = NSLocalizedString("chatsbrowser.sign_in_msg", comment: "Please sign in to view chats")
    let l_noChatsMsg = NSLocalizedString("chatsbrowser.no_chats_msg", comment: "You don't have any chats yet\nStart a conversation from an item's page")
    let l_searchPrompt = NSLocalizedString("chatsbrowser.search_prompt", comment: "Search Chats")
    let l_navTitle = NSLocalizedString("chatsbrowser.nav_title", comment: "Chats")

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
                if !env.authenticated {
                    Text(l_signInMsg)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                } else if chats.isEmpty {
                    List {
                        HStack {
                            Spacer()
                            Text(l_noChatsMsg)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                    .refreshable(action: { fetchChats() })

                } else {
                    let filteredChats = chats.filter { searchText.isEmpty || $0.fullName().contains(searchText) }

                    List(filteredChats, id: \.uid) { user in
                        NavigationLink(destination: ChatView(recipient: user)) {
                            ChatRow(user: user)
                        }
                    }
                    .refreshable(action: { fetchChats() })
                    .searchable(text: $searchText, prompt: l_searchPrompt)
                }
            }
            .navigationTitle(l_navTitle)
        }
        .navigationViewStyle(.stack)
        .onAppear { fetchChats() }
    }
}

struct ChatsBrowser_Previews: PreviewProvider {
    static var previews: some View {
        ChatsBrowser()
    }
}
