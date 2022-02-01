//
//  GlobalFunctions.swift
//  Messenger
//
//  Created by Nir Zioni on 10/01/2022.
//

import Foundation

/*fileUrl example: https://firebasestorage.googleapis.com/v0/b/messengar-9328d.appspot.com/o/Avatars%2F_ARhV6JYnDbe0Oi8jUSLnThE4mn62.jpg?alt=media&token=e876e87a-e343-4d65-a041-f58ae35cef16
 */
func fileNameFrom(fileUrl: String) -> String{
    return ((fileUrl.components(separatedBy: "_").last)!.components(separatedBy: "?").first!).components(separatedBy: ".").first!
}


func timeElapsed(_ date: Date) -> String {
    var elapsed = ""
    let seconds = Date().timeIntervalSince(date)
    if seconds < 60 {
        elapsed = "Just now"
    } else if seconds < 60 * 60 {
        let minutes = Int(seconds/60)
        let minText = minutes > 1 ? "mins" : "min"
        elapsed = "\(minutes) \(minText)"
    } else if seconds < 24 * 60 * 60 {
        let hours = Int(seconds / (60 * 60))
        let hoursText = hours > 1 ? "hours" : " hour"
        elapsed = "\(hours) \(hoursText)"
    } else {
        elapsed = date.longDate()
    }
    
    return elapsed
}
