//
//  FirebaseUserListener.swift
//  Messenger
//
//  Created by Nir Zioni on 03/01/2022.
//

import Foundation
import Firebase
import RealmSwift
import FirebaseAuth
import FirebaseFirestore
import CoreMedia
import UIKit

class FirebaseUserListener{
    
    static let shared = FirebaseUserListener()
    
    private init(){}
    
    //MARK: - Login
    func loginUserWithEmail(email: String, password: String, complition: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            if error == nil && authDataResult!.user.isEmailVerified{
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                complition(error, true)
            } else{
                print("Email is not verified")
                complition(error , false)
            }
            
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, complition: @escaping (
        _ error: Error?) -> Void){
            
        Auth.auth().createUser(withEmail: email, password: password) {
            (authDataResult, error) in
            
            complition(error)
            
            if error == nil {
                //send verification email
                authDataResult!.user.sendEmailVerification { (error) in
                    print("Auth email sent with error: ", error?.localizedDescription)
                }
                
                //create user and save it
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey, I'm using Messenger!")
                    saveUserLocally(user)
                    self.saveUsersForFirestore(user)
                }
            }
        }
    }
    
    //MARK: - Resend link methods
    func resendVerificationEmail(email: String, commplition: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().currentUser?.reload(completion: { (error) in
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                commplition(error)
            })
        })
    }
    
    func resetPasswordFor(email: String, complition: @escaping (_ error: Error?) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            complition(error)
        }
    }
    
    func logOutCurrentUser(complition: @escaping (_ error: Error?) -> Void){
        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            complition(nil)
            
        } catch let error as NSError {
            complition(error)
        }
        
        
    }
    
    
    //MARK: - Save users
    func saveUsersForFirestore(_ user:User){
        do {
            try FirebaseReference(.User).document(user.id).setData(from: user)
        } catch  {
            print(error.localizedDescription,  "adding user")
        }
    }
    
    //MARK: - Download user
    func downloadUserFromFirebase(userId: String, email: String? = nil){
        
        FirebaseReference(.User).document(userId).getDocument { querySnapshot, error in
            guard let document = querySnapshot else{
                print("No document for user", userId)
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject{
                    saveUserLocally(user)
                }
                else{
                    print("Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user", error)
            }
            
        }
    }
    
    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User] ) -> Void) {
        var users: [User] = []
        
        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, Error) in
            guard let document = querySnapshot?.documents else {
                print("no documents in all users")
                return
            }
            
            let allUsers = document.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            //Remove the logged in user
            for user in allUsers {
                if User.currentId != user.id {
                    users.append(user)
                }
            }
            
            completion(users)
        }
    }
    
    func downloadUsersFromFirebase(withIds: [String], completion: @escaping (_ allUsers: [User] ) -> Void) {
        var count = 0
        var userArray: [User] = []
        
        for userId in withIds {
            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in
                guard let document = querySnapshot else {
                    print("No document for user", userId)
                    return
                }

                let user = try? document.data(as: User.self)
                userArray.append(user!)
                count += 1
                
                if count == withIds.count {     //finished all users
                    completion(userArray)
                }
            }
        }
    }
    
}


