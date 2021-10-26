//
//  ChatView.swift
//  Earthify
//
//  Created by Rehatbir Singh on 30/07/2021.
//

import Combine
import FirebaseAuth
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
    
    let l_textFieldHint = NSLocalizedString("chatview.text_field.hint", comment: "Send message")
    
    let l_sendErrorAlertTitle = NSLocalizedString("chatview.send_error_alert.title", comment: "Unable to send message")

    func fetchMessages() {
        messages = runningForPreviews ? previewMessages : env.messageRepository.messages.filter { $0.recipients.contains(recipient.uid!) }
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

            primaryAlertMessage = l_sendErrorAlertTitle
            secondaryAlertMessage = error.localizedDescription
            showingAlert = true
        }
    }

    var body: some View {
        // TODO: make background of upper messages progressively fainter
        VStack {
            if messages.isEmpty {
                Spacer()

                Text("chatview.no_chats_msg \(recipient.firstName)", comment: "This is the beginning of your conversation with recipient. Say hi!")
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
                                let msgIndex = messages.firstIndex(of: message)!

                                if msgIndex != messages.endIndex - 1 {
                                    let nextMsg = messages[msgIndex + 1]
                                    let showAuthor = nextMsg.senderID != author.uid
                                    ChatBubble(content: message.content, author: author.firstName, position: position, showAuthor: showAuthor)
                                } else {
                                    ChatBubble(content: message.content, author: author.firstName, position: position, showAuthor: true)
                                }
                                    
                            }
                            // Scroll to bottom
                            .onAppear {
                                reader.scrollTo(messages.last?.id, anchor: .bottom)
                            }
                            .onChange(of: messages) { _ in
                                withAnimation(Animation.easeInOut) {
                                    reader.scrollTo(messages.last?.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }

            Spacer()

            HStack {
                TextField(l_textFieldHint, text: $newMessageText)
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
                dismissButton: .default(Text("alert_dismiss", comment: "OK"))
            )
        }
        .navigationBarTitle(Text("chatview.chat_with \(recipient.fullName())", comment: "Chat with recipient"), displayMode: .inline)
        .onAppear {
            if !runningForPreviews {
                let currentUID = Auth.auth().currentUser?.uid

                if let user = env.userRepository.users.first(where: { $0.uid == currentUID }) {
                    currentUser = user
                }

                // Update 'messages' state when MessageRepository is updated
                messagesCancellable = env.messageRepository.$messages.sink { newMessages in
                    messages = newMessages.filter { $0.recipients.contains(recipient.uid!) }
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
