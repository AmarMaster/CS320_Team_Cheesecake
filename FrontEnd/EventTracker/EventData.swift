//
//  EventData.swift
//  EventTracker
//

import Foundation

struct EventData: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    let location: String
    var date: Date
    var time: Date
}
