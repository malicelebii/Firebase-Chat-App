//
//  ChatViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import Foundation

protocol ChatViewModelDelegate {
    func createMessageId() -> String?
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String?)
}

final class ChatViewModel: ChatViewModelDelegate {
    let databaseManager: DatabaseManagerDelegate
    weak var view: ChatViewDelegate?
    var messages = [Message]()
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    let selfSender: Sender? = {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return nil }
        
        return Sender(photoURL: "", senderId: email, displayName: "Joe Smith")
    }()
  
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
          }
    
    func createMessageId() -> String? {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String, let otherUserEmail = view?.otherUserEmail else { return nil}
        let dateString = ChatViewModel.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(DatabaseManager.safeEmail(email: currentEmail))_\(dateString))"
        print("create message id : \(newIdentifier)")
        return newIdentifier
    }
    
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String?) {
        databaseManager.createNewConversation(with: otherUserEmail, name: name ?? "User" ,firstMessage: firstMessage) { result in
            if result {
                print("message sent")
                print(firstMessage)
            }else {
                print("failed to send message")
            }
        }
    }
}
