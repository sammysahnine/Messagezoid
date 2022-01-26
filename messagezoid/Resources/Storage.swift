//
//  Storage.swift
//  messagezoid
//
//  Created by Sammy Sahnine on 24/01/2022.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    //Create private references
    public typealias UploadPFPDone = (Result<String, Error>) -> Void
    public func uploadpfp(with data: Data, name: String, completion: @escaping (Result<String, Error>) -> Void) {
        storage.child("ProfilePic/\(name)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                completion(.failure(StorageErrors.failedupload))
                return
            }
            
            self.storage.child("ProfilePic/\(name)").downloadURL(completion: {url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedurlfetch))
                    return
                }
                
                let urlString = url.absoluteString
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedupload
        case failedurlfetch
    }
    
    //Creates public error list for storage
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedurlfetch))
                return
            }
            completion(.success(url))
        })
    }
}


//Uploading to Firebase Stroage from Swift: https://firebase.google.com/docs/storage/ios/upload-files, https://www.youtube.com/watch?v=S3vUl6KiUs


