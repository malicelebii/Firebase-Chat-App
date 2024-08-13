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
    
    init(databaseManager: DatabaseManagerDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    func login(withEmail: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: withEmail, password: password) { [weak self] result, error in
            guard let self = self else { return }
            self.view?.didLogin()
        }
    }
    
    func loginWithFB(token: String) {
        let fbRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        fbRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else { print("Failed to make fb graph request"); return }
          
            let credential = FacebookAuthProvider.credential(withAccessToken:  AccessToken.current!.tokenString)
            
            guard let userName = result["name"] as? String, let email = result["email"] as? String else { print("Failed to get email and name from fb result"); return }
            let nameComponents = userName.components(separatedBy: " ")
            
            self.databaseManager.userExist(with: email) { exist in
                if !exist {
                    self.databaseManager.insertUser(with: ChatAppUser(firstName: nameComponents[0], lastName: nameComponents[1], email: email))
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
                    let firstName = user.profile?.givenName
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
