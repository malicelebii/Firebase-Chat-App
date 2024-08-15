//
//  ChatAppUser.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 12.08.2024.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let email: String
    
    var safeEmail : String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
