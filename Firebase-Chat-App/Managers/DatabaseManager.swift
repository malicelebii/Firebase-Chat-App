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
            completion(true)
        }
    }
}
