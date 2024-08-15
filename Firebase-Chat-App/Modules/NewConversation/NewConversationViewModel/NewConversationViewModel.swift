//
//  NewConversationViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 15.08.2024.
//

import Foundation

protocol NewConversationViewModelDelegate {
    func searchUsers(query: String)
    func filteredUsers(with term: String) -> [[String: String]]
}

final class NewConversationViewModel: NewConversationViewModelDelegate {
    weak var view: NewConversationViewDelegate?
    let databaseManager: DatabaseManagerDelegate
    var users = [[String: String]]()
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func searchUsers(query: String) {
        databaseManager.getAllUsers { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let users):
                self.users = users
                self.users = filteredUsers(with: query)
                print(self.users)
                self.view?.didSearchUser()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func filteredUsers(with term: String) -> [[String: String]] {
        let results: [[String: String]] = self.users.filter {
            guard let name = $0["name"]?.lowercased() else {
            
                return false
            }
            return name.hasPrefix(term.lowercased())
        }
        return results
    }
}
