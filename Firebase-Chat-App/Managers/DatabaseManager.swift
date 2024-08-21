//
//  DatabaseManager.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 12.08.2024.
//

import Foundation
import FirebaseDatabase
import MessageKit

protocol DatabaseManagerDelegate {
    func userExist(with email: String, completion: @escaping ((Bool) -> Void))
    func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void)
    func getAllUsers(completion: @escaping (Result<[[String : String]], Error>) -> Void)
    func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void)
    func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void)
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void)
    func sendMessage(to conversation: String, otherUserEmail: String, name:String, message: Message, completion: @escaping (Bool) -> Void)
    func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void)
    func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void)
    func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void)
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
            guard snapshot.value  != nil else {
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
    func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(email: currentEmail)
        database.child("\(safeEmail)").observeSingleEvent(of: .value) { [weak self] snapShot in
            guard let self = self else { return }
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
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ]
            ]
            
            let recipientNewConversationData = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ]
            ]
            
            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) {[weak self] snapShot in
                
                guard let self = self else { return }
                if var conversations = snapShot.value as? [[String: Any]] {
                    conversations.append(recipientNewConversationData)
                    self.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }else {
                    self.database.child("\(otherUserEmail)/conversations").setValue([recipientNewConversationData])
                }
            }
            
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                // conversation array exists for current user
                // you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                self.database.child("\(safeEmail)").setValue(userNode) { [weak self] error, _ in
                    guard let self = self else { return }
                    guard error == nil else { completion(false);  return }
                    self.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
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
                    self.finishCreatingConversation(name: name, conversationID: conversationId, firstMessage: firstMessage, completion: completion)
                }
            }
        }
    }
    
    func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
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
            "is_email": false,
            "name": name
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
    func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetchConversations))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dict in
                guard let conversationId = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let otherUserEmail = dict["other_user_email"] as? String,
                      let latestMessage = dict["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else { return nil}

                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: conversationId, latestMessage: latestMessageObject, name: name, othetUserEmail: otherUserEmail)
            }
            completion(.success(conversations))
        }
    }
    
    /// Get all messages for a given conversation
    func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapShot in
            guard let value = snapShot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetchMessages))
                return
            }
            
            let messages: [Message] = value.compactMap { dict in
                guard let messageId = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let senderEmail = dict["sender_email"] as? String,
                      let content = dict["content"] as? String,
                      let type = dict["type"] as? String,
                      let dateString = dict["date"] as? String,
                      let date = ChatViewModel.dateFormatter.date(from: dateString) else { return nil}

                var kind: MessageKind?
                if type == "photo" {
                    guard let imageUrl = URL(string: content), let placeholder = UIImage(systemName: "plus") else { return nil}
                    let media = Media(url: imageUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if type == "video" {
                    guard let videoUrl = URL(string: content), let placeholder = UIImage(systemName: "plus") else { return nil}
                    let media = Media(url: videoUrl, image: nil, placeholderImage: placeholder, size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                else {
                    kind = .text(content)
                }
                guard let finalKind = kind else { return nil}
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                return Message(sender: sender, messageId: messageId, sentDate: date, kind: finalKind)
            }
            completion(.success(messages))
        }
    }
    
    /// Send a message with target conversation and message
    func sendMessage(to conversation: String, otherUserEmail: String, name: String, message: Message, completion: @escaping (Bool) -> Void) {
        // add new messages to messages
        // update sender latest message
        // update recipient latest message
        database.child("\(conversation)/messages").observeSingleEvent(of: .value) { [weak self] snapShot in
            guard let self = self else { return }
            guard var currentMessages = snapShot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            var messageContent = ""
            
            switch message.kind {
                
            case .text(let messageText):
                messageContent = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageContent = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    messageContent = targetUrlString
                }
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
            let messageDate = message.sentDate
            let dateString = ChatViewModel.dateFormatter.string(from: messageDate)
            
            guard let email = UserDefaults.standard.value(forKey: "email") as? String  else { completion(false); return }
            let currentUserEmail = DatabaseManager.safeEmail(email: email)
            let message: [String: Any] = [
                "id": message.messageId,
                "type": message.kind.messageKindString,
                "content": messageContent,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_email": false,
                "name": name
            ]
            currentMessages.append(message)
            self.database.child("\(conversation)/messages").setValue(currentMessages) { [weak self] error, _ in
                guard error == nil else {completion(false); return }
                self?.database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                    guard var currentConversations = snapShot.value as? [[String: Any]] else { return }
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": messageContent
                    ]
                    var position = 0
                    var updatedConversation: [String: Any]?
                    for var _conversation in currentConversations {
                        if _conversation["id"] as? String == conversation {
                            // Konuşmayı güncelleyin
                            _conversation["latest_message"] = updatedValue
                            updatedConversation = _conversation
                            break
                        }
                        position += 1
                    }
                    guard let finalConversation = updatedConversation else { return }
                    currentConversations[position] = finalConversation
                    
                    self?.database.child("\(currentUserEmail)/conversations").setValue(currentConversations) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { snapShot in
                            guard var otherConversations = snapShot.value as? [[String: Any]] else { return }
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": messageContent
                            ]
                            var position = 0
                            var updatedConversation: [String: Any]?
                            for var _conversation in otherConversations {
                                if _conversation["id"] as? String == conversation {
                                    // Konuşmayı güncelleyin
                                    _conversation["latest_message"] = updatedValue
                                    updatedConversation = _conversation
                                    break
                                }
                                position += 1
                            }
                            guard let finalConversation = updatedConversation else { return }
                            otherConversations[position] = finalConversation
                            
                            self?.database.child("\(otherUserEmail)/conversations").setValue(otherConversations) { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let safeEmail = DatabaseManager.safeEmail(email: email)
        database.child("\(safeEmail)/conversations").observeSingleEvent(of: .value) {[weak self] snapShot in
            guard let self = self else { return }
            if var conversations = snapShot.value as? [[String: Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String, id == conversationId {
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                self.database.child("\(safeEmail)/conversations").setValue(conversations) { error, _ in
                    guard error == nil else { completion(false); print("Failed to write new conversation array"); return }
                    print("deleted conversation")
                    completion(true)
                }
            }
        }
    }
}

extension DatabaseManager {
    func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child(path).observeSingleEvent(of: .value) { snapShot in
            guard let value = snapShot.value else { completion(.failure(DatabaseError.failedToFetchData)); return }
            completion(.success(value))
        }
    }
}
