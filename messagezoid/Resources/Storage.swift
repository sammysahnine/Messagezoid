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
    //Uploading profile picture
        storage.child("ProfilePic/\(name)").putData(data, metadata: nil, completion: { metadata, error in
        //Puts the data in a certain container in the server storage
            guard error == nil else {
                completion(.failure(StorageErrors.failedupload))
                return
                //Returns error in case of upload failure
            }
            
            self.storage.child("ProfilePic/\(name)").downloadURL(completion: {url, error in
                guard let url = url else {
                    completion(.failure(StorageErrors.failedurlfetch))
                    return
                    //Returns error if cannot get URL of profile picture, otherwise
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
                //Returns the URL as a string
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
        //Gets the download URL for any images
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedurlfetch))
                    //Returns either an error if fetching failed...
                return
            }
            completion(.success(url))
            //... or the image URL in case of success.
        })
    }
}


//Uploading to Firebase Stroage from Swift: https://firebase.google.com/docs/storage/ios/upload-files, https://www.youtube.com/watch?v=S3vUl6KiUs


