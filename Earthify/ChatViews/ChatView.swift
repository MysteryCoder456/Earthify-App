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
    
    let user: AppUser
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    func fetchMessages() {
        messages = runningForPreviews ? previewMessages : env.messageRepository.messages
    }
    
    func sendMessage() {
        // TODO: Make this function
    }
    
    var body: some View {
        VStack {
            if messages.isEmpty {
                Spacer()
                
                Text("This is the beginning of your conversation with \(user.firstName). Say hi!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                ScrollView {
                    ScrollViewReader { reader in
                        LazyVStack {
                            ForEach(messages, id: \.id) { message in
                                Text(message.content)
                            }
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
        .navigationBarTitle("Chat with \(user.firstName) \(user.lastName)", displayMode: .inline)
        .onAppear {
            if !runningForPreviews {
                // Fetch new messages whenever message repository updates
                messageRepoCancellable = env.messageRepository.objectWillChange.sink { _ in
                    fetchMessages()
                }
            }
            fetchMessages()
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView(user: previewUsers.first!)
        }
    }
}
