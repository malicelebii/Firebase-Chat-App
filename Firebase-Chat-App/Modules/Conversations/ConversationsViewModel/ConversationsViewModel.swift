//
//  ConversationsViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 13.08.2024.
//

import Foundation

protocol ConversationsViewModelDelegate {
    func fetchConversations()
}

final class ConversationsViewModel: ConversationsViewModelDelegate {
    weak var view: ConversationsViewDelegate?
    let databaseManager: DatabaseManagerDelegate?
    
    func fetchConversations() {
        self.view?.didFetchConversations()
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func createNewConversation(result: [String: String]) {
        guard let name = result["name"], let email = result["email"] else { return }
        let chatVC = ChatViewController(otherUserEmail: email)
        chatVC.isNewConversation = true
        chatVC.title = name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        view?.didCreateNewConversation(chatVC: chatVC)
    }
}
