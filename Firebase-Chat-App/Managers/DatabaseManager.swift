//
//  DatabaseManager.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 12.08.2024.
//

import Foundation
import FirebaseDatabase

protocol DatabaseManagerDelegate {
    func userExist(with email: String, completion: @escaping ((Bool) -> Void))
    func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void)
    func getAllUsers(completion: @escaping (Result<[[String : String]], Error>) -> Void)
    func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void)
    func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void)
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void)
    func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void)
    func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void)
}

final class DatabaseManager: DatabaseManagerDelegate {
    static let shared = DatabaseManager()
    let database = Database.database().reference()
    
    static func safeEmail(email: String) -> String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    func userExist(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ]) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value) { snapShot in
                if var usersCollection = snapShot.value as? [[String: String]] {
                    // append to user dictionary
                    let newUser = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newUser)
                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else { completion(false); return }
                    }
                    completion(true)
                } else {
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else { return }
                    }
                    completion(true)
                }
            }
            
        
        }
    }
    
    func getAllUsers(completion: @escaping (Result<[[String : String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetchUsers))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Sending messages / Conversations

extension DatabaseManager {
    /// Creates a new conversation with target user email and first message sent
    func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        database.child("\(safeEmail)").observeSingleEvent(of: .value) { snapShot in
            guard var userNode = snapShot.value as? [String: Any] else { completion(false); print("user not found"); return }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewModel.dateFormatter.string(from: messageDate)
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            
            let newConversationData = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                self.database.child("\(safeEmail)").setValue(userNode) { [weak self] error, _ in
                    guard let self = self else { return }
                    guard error == nil else { completion(false);  return }
                    self.finishCreatingConversation(conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }else {
                // conversation array does not exist
                // create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                self.database.child("\(safeEmail)").setValue(userNode) { [weak self] error, _ in
                    guard let self = self else { return }
                    guard error == nil else { completion(false);  return }
                    self.finishCreatingConversation(conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        var messageContent = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            messageContent = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewModel.dateFormatter.string(from: messageDate)
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String  else { completion(false); return }
        let currentUserEmail = DatabaseManager.safeEmail(email: email)
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": messageContent,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_email": false
        ]
        
        let value: [String: Any] = [
            "messages": [
                message
            ]
        ]
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else { completion(false); return }
            completion(true)
        }
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Get all messages for a given conversation
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Send a message with target conversation and message
    func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
}
