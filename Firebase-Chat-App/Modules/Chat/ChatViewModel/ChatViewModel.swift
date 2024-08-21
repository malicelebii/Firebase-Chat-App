//
//  ChatViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import UIKit

protocol ChatViewModelDelegate {
    func createMessageId() -> String?
    func sendMessage(to conversation: String, otherUserEmail: String, name: String, message: Message)
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, name: String?)
    func getAllMessagesForConversation(with id: String)
    func uploadMessagePhoto(with data: Data, name: String)
    func uploadMessageVideo(with fileUrl: URL, name: String)
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
    
    func uploadMessagePhoto(with data: Data, name: String) {
        guard let messageId = createMessageId(), let sender = selfSender else { return }
        let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
        
        
        storageManager.uploadMessagePhoto(with: data, fileName: fileName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let urlString):
                guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus"), let conversationId = self.view?.conversationId, let otherUserEmail = self.view?.otherUserEmail else { return }
                let media = Media(url: url , image: nil, placeholderImage: placeholder, size: .zero)
                let message = Message(sender: sender, messageId: messageId, sentDate: Date(), kind: .photo(media))
                sendMessage(to: conversationId , otherUserEmail: otherUserEmail , name: name , message: message)
                print("Uploaded message photo: \(urlString)")
            case .failure(let error):
                print("Message Photo Upload Error")
            }
        }
    }
    
    func uploadMessageVideo(with fileUrl: URL, name: String) {
        guard let messageId = createMessageId(), let sender = selfSender else { return }
        let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
        
        
        storageManager.uploadMessageVideo(with: fileUrl, fileName: fileName) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let urlString):
                guard let url = URL(string: urlString), let placeholder = UIImage(systemName: "plus"), let conversationId = self.view?.conversationId, let otherUserEmail = self.view?.otherUserEmail else { return }
                let media = Media(url: url , image: nil, placeholderImage: placeholder, size: .zero)
                let message = Message(sender: sender, messageId: messageId, sentDate: Date(), kind: .video(media))
                sendMessage(to: conversationId , otherUserEmail: otherUserEmail , name: name , message: message)
                print("Uploaded message video: \(urlString)")
            case .failure(let error):
                print("Message Video Upload Error")
            }
        }
    }
}
