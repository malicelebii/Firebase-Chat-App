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
    func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion)
}

final class StorageManager: StorageManagerDelegate {
    static let shared = StorageManager()
    let storage = Storage.storage().reference()
    
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        print("data : \(data)")
        print("fileName: \(fileName)")
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
            guard let self = self else { return }
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
        self.storage.child("message_images/\(fileName)").putData(data, metadata: nil) { [weak self] metaData, error in
            guard let self = self else { return }
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
    
    func uploadMessageVideo(with fileUrl: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        print("fileName: \(fileName)")
        self.storage.child("message_videos/\(fileName)").putFile(from: fileUrl, metadata: nil) {[weak self] metaData, error in
            guard let self = self else { return }
            guard error == nil else {
                print("Failed to upload video file to firabase")
                print(error)
                completion(.failure(StorageError.failedToUpload))
                return
            }
         
            self.storage.child("message_videos/\(fileName)").downloadURL { url, error in
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
