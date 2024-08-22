//
//  ProfileViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 15.08.2024.
//

import UIKit
import SDWebImage

protocol ProfileViewModelDelegate {
    func setProfilePicture(for path: String, imageView: UIImageView)
}

final class ProfileViewModel: ProfileViewModelDelegate {
    let storageManager: StorageManagerDelegate
    
    init(storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.storageManager = storageManager
    }
}

extension ProfileViewModel {
    func setProfilePicture(for path: String, imageView: UIImageView) {
        storageManager.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    imageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
