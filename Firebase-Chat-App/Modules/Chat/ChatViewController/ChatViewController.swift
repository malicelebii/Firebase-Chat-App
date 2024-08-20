//
//  ChatViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 13.08.2024.
//

import UIKit
import MessageKit
import InputBarAccessoryView

protocol ChatViewDelegate: AnyObject {
    func didCreateConversation()
    func didFetchMessages()
    var otherUserEmail: String { get}
}

class ChatViewController: MessagesViewController  {
    let chatViewModel = ChatViewModel()
    var otherUserEmail: String
    var conversationId: String?
    var isNewConversation = false
    
    init(otherUserEmail: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = otherUserEmail
        super.init(nibName: nil, bundle: nil)
        if let conversationId = conversationId {
            chatViewModel.getAllMessagesForConversation(with: conversationId)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatViewModel.view = self
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let selfSender = chatViewModel.selfSender, let messageId = chatViewModel.createMessageId() else { return }
        
        print("Sending \(text)")
        let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        // Send Message
        if isNewConversation {
            chatViewModel.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title)
        }else {
            guard let conversationId = conversationId, let name = self.title else { return }
            chatViewModel.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, message: message)
        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = chatViewModel.selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatViewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatViewModel.messages.count
    }    
}

extension ChatViewController: ChatViewDelegate {
    func didFetchMessages() {
        DispatchQueue.main.async{ [weak self] in
            guard let self = self else { return }
            self.messagesCollectionView.reloadDataAndKeepOffset()
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    
    func didCreateConversation() {
        self.isNewConversation = false
    }
}
