//
//  ProfileView.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 22.08.2024.
//

import Foundation

enum ProfileViewType {
    case info, logout
}


struct ProfileView {
    let viewType: ProfileViewType
    let title: String
    let handler: (() -> Void)?
}
