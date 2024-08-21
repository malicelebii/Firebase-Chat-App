//
//  ChatViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import Foundation

protocol ChatViewModelDelegate {
    func createMessageId() -> String?
    func sendMessage(to conversation: String, otherUserEmail: String, name: String, message: Message)
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String?)
    func getAllMessagesForConversation(with id: String)
}

final class ChatViewModel: ChatViewModelDelegate {
    let databaseManager: DatabaseManagerDelegate
    let storageManager: StorageManagerDelegate
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
        let safeEmail = DatabaseManager.safeEmail(email: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Me")
    }()
  
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared, storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.databaseManager = databaseManager
        self.storageManager = storageManager
    }
    
    func createMessageId() -> String? {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String, let otherUserEmail = view?.otherUserEmail else { return nil}
        let dateString = ChatViewModel.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(DatabaseManager.safeEmail(email: currentEmail))_\(dateString))"
        print("create message id : \(newIdentifier)")
        return newIdentifier
    }
    
    func sendMessage(to conversation: String, otherUserEmail: String, name: String ,message: Message) {
        databaseManager.sendMessage(to: conversation, otherUserEmail: otherUserEmail, name: name, message: message) { result in
            if result {
                print("message sent")
            }
            else {
                print("failedd to send message")
            }
        }
    }
    
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String?) {
        databaseManager.createNewConversation(with: otherUserEmail, name: name ?? "User" ,firstMessage: firstMessage) { [weak self] result in
            guard let self = self else { return }
            if result {
                print("message sent")
                print(firstMessage)
                self.view?.didCreateConversation()
            }else {
                print("failed to send message")
            }
        }
    }
    
    func getAllMessagesForConversation(with id: String) {
        databaseManager.getAllMessagesForConversation(with: id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let messages):
                self.messages = messages
                self.view?.didFetchMessages()
            case .failure(let error):
                print(error)
            }
        }
    }
}
