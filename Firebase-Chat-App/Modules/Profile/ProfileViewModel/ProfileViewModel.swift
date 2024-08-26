//
//  ProfileViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 15.08.2024.
//

import UIKit
import SDWebImage
import JGProgressHUD

protocol ProfileViewModelDelegate {
    func setProfilePicture(for path: String, imageView: UIImageView)
}

final class ProfileViewModel: ProfileViewModelDelegate {
    let storageManager: StorageManagerDelegate
    let spinner = JGProgressHUD()
    
    init(storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.storageManager = storageManager
    }
}

extension ProfileViewModel {
    func setProfilePicture(for path: String, imageView: UIImageView) {
        spinner.show(in: imageView)
        storageManager.downloadURL(for: path) { result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.spinner.dismiss()
                    imageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
