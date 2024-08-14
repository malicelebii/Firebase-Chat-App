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
    
    func fetchConversations() {
        self.view?.didFetchConversations()
    }
}
