//
//  StorageManager.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 14.08.2024.
//

import Foundation
import FirebaseStorage

typealias UploadPictureCompletion = (Result<String, Error>) -> Void

protocol StorageManagerDelegate {
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping (Result<String, Error>) -> Void)
    func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void)
    func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion)
}

final class StorageManager: StorageManagerDelegate {
    static let shared = StorageManager()
    let storage = Storage.storage().reference()
    
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        print("data : \(data)")
        print("fileName: \(fileName)")
        self.storage.child("images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else {
                print("Failed to upload data to firabase for picture")
                print(error)
                completion(.failure(StorageError.failedToUpload))
                return
            }
         
            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Donwload url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        print("data : \(data)")
        print("fileName: \(fileName)")
        self.storage.child("message_images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else {
                print("Failed to upload data to firabase for picture")
                print(error)
                completion(.failure(StorageError.failedToUpload))
                return
            }
         
            self.storage.child("message_images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Donwload url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else { completion(.failure(StorageError.failedToGetDownloadUrl)); return }
            completion(.success(url))
        }
    }
}
