//
//  User.swift
//  Messenger
//
//  Created by Nir Zioni on 03/01/2022.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER){
              
                let decoder = JSONDecoder()
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user from user defaults", error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    //Equalty func
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}


func saveUserLocally(_ user: User){
    let encoder = JSONEncoder()
    
    do{
        let data = try encoder.encode(user)
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print ("error saving user locally", error.localizedDescription)
    }
}

//Used only once
func createDummyUsers(){
    
    let names = ["Bat Zion", "King David", "Dani Din"]
    
    var imageIndex = 1
    var userIndex = 1
    
    for i in 0..<3 {
        let id = UUID().uuidString
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"
        FileStorage.uploadImage(UIImage(named: "user\(imageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = User(id: id, username: names[i], email: "user\(userIndex)mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No status")
            
            userIndex += 1
            FirebaseUserListener.shared.saveUsersForFirestore(user)
        }
        imageIndex += 1
        if imageIndex == 3 {
            imageIndex = 1
        }
    }
}


