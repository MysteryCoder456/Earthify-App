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
    @State var newMessageText = ""
    
    // Alert details
    @State var primaryAlertMessage = ""
    @State var secondaryAlertMessage = ""
    @State var showingAlert = false
    
    // Recipients
    @State var currentUser: AppUser = previewUsers[1]
    let recipient: AppUser
    
    @State var messages: [Message] = []
    
    // For updating 'messages' state when MessageRepository is updated
    @State var messagesCancellable: AnyCancellable?
    
    let runningForPreviews = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    
    func fetchMessages() {
        messages = runningForPreviews ? previewMessages : env.messageRepository.messages.filter({ $0.recipients.contains(recipient.uid!) })
    }
    
    func sendMessage() {
        // Ensure that user is signed in
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        // Ensure that message content isn't empty
        newMessageText = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newMessageText.isEmpty else { return }
        
        let newMessage = Message(senderID: currentUID, recipients: [currentUID, recipient.uid!], content: newMessageText)
        
        do {
            try env.messageRepository.updateMessage(newMessage)
            newMessageText = ""
        } catch {
            print("Could not send message: \(error.localizedDescription)")
            
            primaryAlertMessage = "Unable to send message"
            secondaryAlertMessage = error.localizedDescription
            showingAlert = true
        }
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
                            .onChange(of: messages) { _ in
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
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(primaryAlertMessage),
                message: Text(secondaryAlertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitle("Chat with \(recipient.firstName) \(recipient.lastName)", displayMode: .inline)
        .onAppear {
            if !runningForPreviews {
                let currentUID = Auth.auth().currentUser?.uid
                
                if let user = env.userRepository.users.first(where: { $0.uid == currentUID }) {
                    currentUser = user
                }
                
                // Update 'messages' state when MessageRepository is updated
                messagesCancellable = env.messageRepository.$messages.sink { newMessages in
                    messages = newMessages.filter({ $0.recipients.contains(recipient.uid!) })
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
