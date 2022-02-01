//
//  Status.swift
//  Messenger
//
//  Created by Nir Zioni on 11/01/2022.
//

import Foundation

enum Status: String {
    
    
    case Available = "Available"
    case Busy = "Busy"
    case AtSchool = "At School"
    case AtTheMovie = "At The Movie"
    case AtWork = "At Work"
    case BattaryAboutToDie = "Battary About To Die"
    case CantTalk = "Cant Talk"
    case InAMeeting = "In a meeting"
    case AtTheGym = "At the gym"
    case Sleeping = "Sleeping"
    case UrgentCallsOnly = "Urgent Calls Only"
    
    static var array: [Status] {
        var a:[Status]  = []
        
        switch Status.Available {
        case .Available:
            a.append(.Available); fallthrough
        case .Busy:
            a.append(.Busy); fallthrough
        case .AtSchool:
            a.append(.AtSchool); fallthrough
        case .AtTheMovie:
            a.append(.AtTheMovie); fallthrough
        case .AtWork:
            a.append(.AtWork); fallthrough
        case .BattaryAboutToDie:
            a.append(.BattaryAboutToDie); fallthrough
        case .CantTalk:
            a.append(.CantTalk); fallthrough
        case .AtTheGym:
            a.append(.AtTheGym); fallthrough
        case .Sleeping:
            a.append(.Sleeping); fallthrough
        case .UrgentCallsOnly:
            a.append(.UrgentCallsOnly);
        case .InAMeeting:
            a.append(.InAMeeting);
        }
        return a
    }
}
