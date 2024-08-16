//
//  ChatViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 13.08.2024.
//

import UIKit
import MessageKit

protocol ChatViewDelegate: AnyObject {
    var otherUserEmail: String { get}
}

class ChatViewController: MessagesViewController  {
    let chatViewModel = ChatViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        chatViewModel.view = self
        view.backgroundColor = .red
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return chatViewModel.selfSender
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
