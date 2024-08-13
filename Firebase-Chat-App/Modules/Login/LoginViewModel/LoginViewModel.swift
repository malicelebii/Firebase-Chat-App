//
//  LoginViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 5.08.2024.
//

import Foundation
import FirebaseAuth

protocol LoginViewModelDelegate {
    func login(withEmail: String, password: String)
}

final class LoginViewModel: LoginViewModelDelegate {
    var databaseManager: DatabaseManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func login(withEmail: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: withEmail, password: password) { result, error in   
        }
    }
    
    
}
