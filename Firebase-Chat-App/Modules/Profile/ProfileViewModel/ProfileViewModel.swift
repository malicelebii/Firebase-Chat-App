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
    weak var view: ProfileViewControllerDelegate?
    let spinner = JGProgressHUD()
    var data = [ProfileView]()
    
    init(storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.storageManager = storageManager
        setProfileViewData()
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
    
    func setProfileViewData() {
        data.append(ProfileView(viewType: .info, title: "Name: \(UserDefaults.standard.string(forKey: "name") ?? "No name")", handler: nil))
        data.append(ProfileView(viewType: .info, title: "Email: \(UserDefaults.standard.string(forKey: "email") ?? "No email")", handler: nil))
        data.append(ProfileView(viewType: .logout, title: "Logout", handler: { [weak self] in
            self?.view?.showLogOutAlert()
        }))
    }
}
