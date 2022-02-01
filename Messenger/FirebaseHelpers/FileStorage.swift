//
//  FileStorage.swift
//  Messenger
//
//  Created by Nir Zioni on 09/01/2022.
//

import Foundation
import FirebaseStorage
import ProgressHUD
import UIKit

let storage = Storage.storage()

class FileStorage {
    
    //MARK: - Images
    class func uploadImage(_ image: UIImage, directory: String, complition: @escaping(_ documentLink: String?) -> Void){
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        let imageDate = image.jpegData(compressionQuality: 0.6)
        
        var task: StorageUploadTask!
        task = storageRef.putData(imageDate!, metadata: nil, completion: { (metadate, error) in
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("Error uploading image \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                guard let downloadUrl = url else {
                    complition(nil)
                    return
                }
                
                complition(downloadUrl.absoluteString)
            }
        })
        //show file uploading presentege
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    class func downloadImage(imageURL: String, complition: @escaping(_ image: UIImage?) -> Void){
        let imageFileName = fileNameFrom(fileUrl: imageURL)
        if fileExistsAtPath(path: imageFileName) {
            //get the image locally
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentDirectory(filename: imageFileName)) {
                complition(contentsOfFile)
            } else {
                print("Couldn't convert local image")
                complition(UIImage(named: "avatar")) //return some defalt image - this error case
            }
        } else {
            //download from Firebase
            if imageURL != "" {
                let documentUrl = URL(string: imageURL)
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                downloadQueue.async {
                    let data = NSData(contentsOf: documentUrl!)
                    if data != nil { //Successful
                        //Save lacally
                        FileStorage.saveFileLocally(fileDate: data!, fileName: imageFileName)
                        //Go back to main queue
                        DispatchQueue.main.async {
                            complition(UIImage(data: data! as Data))
                        }
                    } else {
                        print("No document in Firebase DB")
                        DispatchQueue.main.async {
                            complition(nil)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Save Locally
    class func saveFileLocally(fileDate: NSData, fileName: String){
        let docUrl =  getDocumentsUrl().appendingPathComponent(fileName, isDirectory: false)
        fileDate.write(to: docUrl, atomically: true)
    }

}


//MARK: - Helpers

func fileInDocumentDirectory(filename: String) -> String {
    return getDocumentsUrl().appendingPathComponent(filename).path
}

func getDocumentsUrl() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    let filePath = fileInDocumentDirectory(filename: path)
    return FileManager.default.fileExists(atPath: filePath)
}
