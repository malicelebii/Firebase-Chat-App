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
