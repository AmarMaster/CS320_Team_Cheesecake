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

struct EventData: Identifiable, Codable {
    let id: Int?
    var name: String
    var description: String
    var location: EventLocation
    var locationString: String
    var coordinate: CLLocationCoordinate2D?
    var time: Date
    var duration: Int
    var details: String
    var imageData: Data?
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, location, locationString, time, duration, details, imageData
    }
    
    init(id: Int? = nil, name: String, description: String, coordinate: CLLocationCoordinate2D, locationString: String, time: Date, duration: Int, details: String, imageData: Data? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.location = EventLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        self.locationString = locationString
        self.coordinate = coordinate
        self.time = time
        self.duration = duration
        self.details = details
        self.imageData = imageData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        location = try container.decode(EventLocation.self, forKey: .location)
        locationString = try container.decode(String.self, forKey: .locationString)
        time = try container.decode(Date.self, forKey: .time)
        duration = try container.decode(Int.self, forKey: .duration)
        details = try container.decode(String.self, forKey: .details)
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
        try container.encode(time, forKey: .time)
        try container.encode(duration, forKey: .duration)
        try container.encode(details, forKey: .details)
        try container.encodeIfPresent(imageData, forKey: .imageData)
    }
}
