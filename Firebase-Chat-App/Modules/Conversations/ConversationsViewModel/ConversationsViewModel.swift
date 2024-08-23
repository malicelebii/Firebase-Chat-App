//
//  ConversationsViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 13.08.2024.
//

import Foundation

protocol ConversationsViewModelDelegate {
    func createNewConversation(result: [String: String])
    func getAllConversations()
    func deleteConversation(conversationId: String)
}

final class ConversationsViewModel: ConversationsViewModelDelegate {
    weak var view: ConversationsViewDelegate?
    let databaseManager: DatabaseManagerDelegate?
    var conversations = [Conversation]()
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else { return }
        let currentConversations = conversations
        if let targetConversation = currentConversations.first(where:  {
            $0.othetUserEmail == DatabaseManager.safeEmail(email: email)
        }) {
            let chatVC = ChatViewController(otherUserEmail: targetConversation.othetUserEmail, id: targetConversation.id)
            chatVC.isNewConversation = false
            chatVC.title = targetConversation.name
            chatVC.navigationItem.largeTitleDisplayMode = .never
            view?.didCreateNewConversation(chatVC: chatVC)
        }else {
            let chatVC = ChatViewController(otherUserEmail: email, id: nil)
            chatVC.isNewConversation = true
            chatVC.title = name
            chatVC.navigationItem.largeTitleDisplayMode = .never
            view?.didCreateNewConversation(chatVC: chatVC)
        }
        
    }
    
    func getAllConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        databaseManager?.getAllConversations(for: safeEmail, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else { return }
                self.conversations = conversations
                self.view?.didFetchConversations()
            case .failure(let error):
                print("failed to get conversations")
            }
        })
    }
    
    func deleteConversation(conversationId: String) {
        databaseManager?.deleteConversation(conversationId: conversationId, completion: { success in
            if success {
                print("silinde")
            }else {
                print("silmede hata")
            }
        })
    }
}
