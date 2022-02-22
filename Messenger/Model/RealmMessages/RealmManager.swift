//
//  RealmManager.swift
//  Messenger
//
//  Created by Nir Zioni on 22/02/2022.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    private init() { }
    
    func saveToRealm<T: Object>(_ object: T) {
        
        do {
            try realm.write {
                realm.add(object, update: .all)
            }
            
        } catch {
            print("Erro saving realm object ", error.localizedDescription)
        }
    }
    
}
