//
//  MessageDataSource.swift
//  Messenger
//
//  Created by Nir Zioni on 17/02/2022.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDataSource{
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        
        return mkMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        
        return mkMessages.count
    }
    
    
}
