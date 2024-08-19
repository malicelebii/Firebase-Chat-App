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
    var otherUserEmail: String { get}
}

class ChatViewController: MessagesViewController  {
    let chatViewModel = ChatViewModel()
    var otherUserEmail: String
    var isNewConversation = false
    
    init(otherUserEmail: String) {
        self.otherUserEmail = otherUserEmail
        super.init(nibName: nil, bundle: nil)
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
        // Send Message
        if isNewConversation {
            let message = Message(sender: selfSender, messageId: messageId, sentDate: Date(), kind: .text(text))
            chatViewModel.createNewConversation(with: otherUserEmail, firstMessage: message, name: self.title)
        }else {
            
        }
        
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = chatViewModel.selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be cached")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return chatViewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return chatViewModel.messages.count
    }    
}

extension ChatViewController: ChatViewDelegate {
    
}
