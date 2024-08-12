//
//  RegisterViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 5.08.2024.
//

import Foundation
import FirebaseAuth

protocol RegisterViewModelDelegate {
    func register(withEmail: String, password: String, firstName: String, lastName: String)
}

final class RegisterViewModel: RegisterViewModelDelegate {
    func register(withEmail: String, password: String, firstName: String, lastName: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: withEmail, password: password) { authResult, error in
            guard authResult != nil, error == nil else {
                return
            }
            DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, email: withEmail))
        }
    }
}
