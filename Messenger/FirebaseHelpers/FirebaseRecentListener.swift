//
//  FirebaseRecentListener.swift
//  Messenger
//
//  Created by Nir Zioni on 01/02/2022.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirebaseRecentListener {
    
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecent: [RecentChat]) -> Void) {
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId)
            .addSnapshotListener { (querySnapshot, error) in
            
                var recentChats: [RecentChat] = []
                guard let documents = querySnapshot?.documents else {
                    print("No documents for recent chats")
                    return
                }
                
                let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                    return try? queryDocumentSnapshot.data(as: RecentChat.self)
                }
                
                //show only chats that have at least 1 messege
                for recent in allRecents {
                    if recent.lastMessage != "" {
                        recentChats.append(recent)
                    }
                }
                
                //Sort the chats by date of last messege
                recentChats.sort(by: { $0.date! > $1.date! })
                completion(recentChats)
        }
    }
    
    //User to recent counter while the user is leaving the active chat room
    func resetRecentCounter(chatRoomId: String){
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId)
            .getDocuments { (querySnapshot, Error) in
                
                guard let documents = querySnapshot?.documents else{
                    print("No documents for this recent")
                    return
                }
                
                let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                    return try? queryDocumentSnapshot.data(as: RecentChat.self)
                }
                
                if allRecents.count > 0 {
                    self.clearUnreadCounter(recent: allRecents.first!) //allRecent should contain only 1 Recent - this is why clearing the first
                }
            
        }
    }
    
    func clearUnreadCounter(recent: RecentChat){
        var newRecent = recent
        newRecent.unreadCounter = 0
        self.saveRecent(newRecent)
    }
    
    func saveRecent(_ recent: RecentChat) {
        
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        } catch {
            print ("Error saving recent chat ", error.localizedDescription)
        }
    }
    
    func deleteRecent(_ recent: RecentChat){
        FirebaseReference(.Recent).document(recent.id).delete()
    }
}
