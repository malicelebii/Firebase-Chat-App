//
//  LoginViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 5.08.2024.
//

import Foundation
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn



protocol LoginViewModelDelegate {
    func login(withEmail: String, password: String)
    func loginWithFB(token: String)
    func loginWithGoogle(withRepresenting: UIViewController)
}

final class LoginViewModel: LoginViewModelDelegate {
    weak var view: LoginViewDelegate?
    var databaseManager: DatabaseManagerDelegate
    var storageManager: StorageManagerDelegate
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared, storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.databaseManager = databaseManager
        self.storageManager = storageManager
    }
    
    func login(withEmail: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: withEmail, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.view?.didLogin()
        }
    }
    
    func loginWithFB(token: String) {
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        fbRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else { print("Failed to make fb graph request"); return }
          
            let credential = FacebookAuthProvider.credential(withAccessToken:  AccessToken.current!.tokenString)
            
            guard let firstName = result["first_name"] as? String,let lastName = result["last_name"] as? String, let email = result["email"] as? String, let picture = result["picture"] as? [String: Any], let data = picture["data"] as? [String: Any], let pictureURL = data["url"] as? String else { print("Failed to get email and name from fb result"); return }
            
            self.databaseManager.userExist(with: email) { exist in
                if !exist {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, email: email)
                    self.databaseManager.insertUser(with: chatUser ) { success in
                        if success {
                            //upload image
                            guard let url = URL(string: pictureURL) else { return }
                            URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
                                guard let data = data else { return }
                                let fileName = chatUser.profilePictureFileName
                                self.storageManager.uploadProfilePicture(with: data, fileName: fileName) { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print(error)
                                    }
                                }
                            }.resume()
                        }
                    }
                }
            }
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let self = self else { return }
                guard authResult != nil, error == nil else {
                    print("FB credential login failed, MFA may be needed \(error)")
                    print(credential)
                    return
                }
                self.view?.didLogin()
                print("Successfully logged in ")
            }
        })
    }
    
    func loginWithGoogle(withRepresenting: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: withRepresenting) { [unowned self] result, error in
            guard let user = result?.user,
               let idToken = user.idToken?.tokenString
             else {
                return
             }
            guard let email = user.profile?.email,
                    let firstName = user.profile?.givenName,
                    let pictureURL = user.profile?.imageURL(withDimension: 200)
                   else {
                print("Failed to fetch email, firstName, lastName")
                return
            }
            let lastName = user.profile?.familyName ?? ""
            
            self.databaseManager.userExist(with: email) { exist in
                if !exist {
                    self.databaseManager.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, email: email))
                }
            }
             let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                            accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let self = self else { return }
                self.view?.didLogin()
            }
        }
    }
}
