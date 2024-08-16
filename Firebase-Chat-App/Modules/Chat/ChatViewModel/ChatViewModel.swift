//
//  ChatViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import Foundation

protocol ChatViewModelDelegate {
    
    func createMessageId() -> String?
}

final class ChatViewModel {
    let databaseManager: DatabaseManagerDelegate
    var messages = [Message]()
    
    let selfSender: Sender? = {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        return Sender(photoURL: "", senderId: email, displayName: "Joe Smith")
    }()
  
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func createMessageId() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .long
        dateFormatter.locale = .current
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") else { return nil}
        let dateString = dateFormatter.string(from: Date())
        let newIdentifier = "\(view?.otherUserEmail)_\(currentEmail)_\(dateString))"
        print("create message id : \(newIdentifier)")
        return newIdentifier
    }
    }
}
