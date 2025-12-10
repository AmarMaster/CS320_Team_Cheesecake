//
//  EventData.swift
//  EventTracker
//

import Foundation
import CoreLocation
import UIKit

struct EventLocation: Codable {
    let latitude: Double
    let longitude: Double
}

struct Duration: Codable {
    let hours: Int
    let minutes: Int?
    
    init(hours: Int, minutes: Int = 0) {
        self.hours = hours
        self.minutes = minutes
    }
}

struct EventData: Identifiable, Codable {
    let id: Int?
    var name: String
    var description: String
    var location: EventLocation
    var locationString: String
    var coordinate: CLLocationCoordinate2D
    var time: Date
    var duration: Duration
    var durationHours: Int { duration.hours }
    var durationMinutes: Int { duration.minutes ?? 0 }
    var details: String
    var adultOnly: Bool
    var cost: Double
    var owner_id: Int?
    var imageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, location, locationString, time, duration, details, adultOnly, cost, owner_id, imageData
    }
    
    init(id: Int? = nil, name: String, description: String, coordinate: CLLocationCoordinate2D, locationString: String, time: Date, durationHours: Int, durationMinutes: Int, details: String, adultOnly: Bool = false, cost: Double = 0, owner_id: Int? = nil, imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.location = EventLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.locationString = locationString
        self.coordinate = coordinate
        self.time = time
        self.duration = Duration(hours: durationHours, minutes: durationMinutes)
        self.details = details
        self.adultOnly = adultOnly
        self.cost = cost
        self.owner_id = owner_id
        self.imageData = imageData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        location = try container.decode(EventLocation.self, forKey: .location)
        
        // TODO:
        // None of these decode properly. They are inconsistent between
        // the backend code and the frontend code: locationString, time,
        // and duration (duration,time done)
        
        //try container.decode(String.self, forKey: .locationString)
        locationString = "locationString is not in the damn database for some reason"
        
        let timeString = try container.decode(String.self, forKey: .time)
        let formatter = ISO8601DateFormatter()
        time = formatter.date(from: timeString) ?? Date.now
        
        duration = try container.decodeIfPresent(Duration.self, forKey: .duration) ?? Duration(hours: 2, minutes: 0)
        
        details = try container.decode(String.self, forKey: .details)
        adultOnly = try container.decodeIfPresent(Bool.self, forKey: .adultOnly) ?? false
        cost = try container.decodeIfPresent(Double.self, forKey: .cost) ?? 0
        owner_id = try container.decodeIfPresent(Int.self, forKey: .owner_id)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(location, forKey: .location)
        try container.encode(locationString, forKey: .locationString)
        let formatter = ISO8601DateFormatter()
        try container.encode(formatter.string(from: time), forKey: .time)
        try container.encode(duration, forKey: .duration)
        try container.encode(details, forKey: .details)
        try container.encode(adultOnly, forKey: .adultOnly)
        try container.encode(cost, forKey: .cost)
        try container.encodeIfPresent(owner_id, forKey: .owner_id)
        try container.encodeIfPresent(imageData, forKey: .imageData)
    }
}
