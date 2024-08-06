//
//  RegisterViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 5.08.2024.
//

import Foundation
import FirebaseAuth

protocol RegisterViewModelDelegate {
    func register(withEmail: String, password: String)
}

final class RegisterViewModel: RegisterViewModelDelegate {
    func register(withEmail: String, password: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: withEmail, password: password) { authResult, error in
            if let result = authResult, error == nil {
                print(result.user)
            }
        }
    }
}
