//
//  ChatView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 30/07/2021.
//

import FirebaseAuth
import Combine
import SwiftUI

struct ChatView: View {
    @EnvironmentObject var env: EnvironmentObjects
    
    @State var messages: [Message] = []
    @State var messageRepoCancellable: AnyCancellable?
    
    @State var newMessageText = ""
    
    @State var currentUser: AppUser = previewUsers[1]
    let recipient: AppUser
    
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    func fetchMessages() {
        messages = runningForPreviews ? previewMessages : env.messageRepository.messages
    }
    
    func sendMessage() {
        // TODO: Make this function
    }
    
    var body: some View {
        // TODO: make background of upper messages progressively fainter
        VStack {
            if messages.isEmpty {
                Spacer()
                
                Text("This is the beginning of your conversation with \(recipient.firstName). Say hi!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                ScrollView {
                    ScrollViewReader { reader in
                        LazyVStack {
                            ForEach(messages, id: \.id) { message in
                                let sentByCurrentUser = currentUser.uid == message.senderID
                                let author = sentByCurrentUser ? currentUser : recipient
                                let position: MessagePosition = sentByCurrentUser ? .primary : .secondary
                                
                                ChatBubble(content: message.content, author: author.firstName, position: position)
                            }
                            // Scroll to bottom
                            .onAppear {
                                reader.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                            .onChange(of: messages.count) { _ in
                                reader.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                TextField("Send message", text: $newMessageText)
                    .padding(8)
                    .background(Color.secondary.opacity(0.4))
                    .cornerRadius(10)
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 33)
                }
            }
            .padding(10)
        }
        .navigationBarTitle("Chat with \(recipient.firstName) \(recipient.lastName)", displayMode: .inline)
        .onAppear {
            if !runningForPreviews {
                // Fetch new messages whenever message repository updates
                messageRepoCancellable = env.messageRepository.objectWillChange.sink { _ in
                    fetchMessages()
                }
                
                let currentUID = Auth.auth().currentUser?.uid
                if let user = env.userRepository.users.first(where: { $0.uid == currentUID }) {
                    currentUser = user
                }
            }
            
            fetchMessages()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(recipient: previewUsers.first!)
        }
    }
}
