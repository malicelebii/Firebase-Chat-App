//
//  ProfileViewModel.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 15.08.2024.
//

import UIKit

protocol ProfileViewModelDelegate {
    func setProfilePicture(for path: String, imageView: UIImageView)
    func downloadImage(imageView: UIImageView, url: URL)
}

final class ProfileViewModel: ProfileViewModelDelegate {
    let storageManager: StorageManagerDelegate
    
    init(storageManager: StorageManagerDelegate = StorageManager.shared) {
        self.storageManager = storageManager
    }
}

extension ProfileViewModel {
    func setProfilePicture(for path: String, imageView: UIImageView) {
        storageManager.downloadURL(for: path) { [weak self] result in
            guard let self = self else { return }
            guard let url = URL(string: path) else { return }
            
            switch result {
            case .success(let url):
                self.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
            
        }.resume()
    }
}
