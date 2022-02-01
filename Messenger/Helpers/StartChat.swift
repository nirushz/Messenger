//
//  StartChat.swift
//  Messenger
//
//  Created by Nir Zioni on 01/02/2022.
//

import Foundation
import UIKit

func StartChat(user1: User, user2: User) -> String {
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    
    return chatRoomId
}

func createRecentItems(chatRoomId: String, users: [User]){
    //check if the user already have recent object
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, Error) in
        <#code#>
    }
}


func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    var chatRoomId = ""
    let value = user1Id.compare(user2Id).rawValue
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    return chatRoomId
}
