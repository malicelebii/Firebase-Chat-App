//
//  RegisterViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 5.08.2024.
//

import Foundation
import FirebaseAuth
import JGProgressHUD

protocol RegisterViewModelDelegate {
    func register(withEmail: String, password: String, firstName: String, lastName: String, image: UIImage?, view: UIView)
}

final class RegisterViewModel: RegisterViewModelDelegate {
    weak var view: RegisterViewDelegate?

    let databaseManager: DatabaseManagerDelegate
    let storageManager: StorageManagerDelegate

    let spinner = JGProgressHUD(style: .dark)
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared, storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.databaseManager = databaseManager
        self.storageManager = storageManager
    }
    
    func register(withEmail: String, password: String, firstName: String, lastName: String, image: UIImage?, view: UIView) {
        spinner.show(in: view)
        Auth.auth().createUser(withEmail: withEmail, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            guard authResult != nil, error == nil else {
                return
            }
            UserDefaults.standard.set(withEmail, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, email: withEmail)
            self.databaseManager.insertUser(with: chatUser) { success in
                print("success: \(success)")
                if success {
                    //upload image
                    guard let image = image, let data = image.pngData() else {
                        return
                    }
                    
                    let fileName = chatUser.profilePictureFileName
                    self.storageManager.uploadProfilePicture(with: data, fileName: fileName) { result in
                        switch result {
                        case .success(let downloadUrl):
                            self.view?.didTapRegister()
                            self.spinner.dismiss()
                            print(downloadUrl)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            }
        }
    }
}
