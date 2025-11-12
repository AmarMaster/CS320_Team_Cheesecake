//
//  EventData.swift
//  EventTracker
//

import Foundation
import CoreLocation

struct EventData: Identifiable {
    let id = UUID()
    var title: String
    var description: String
    var address: String
    var location: CLLocationCoordinate2D?
    var date: Date
    var time: Date
}
