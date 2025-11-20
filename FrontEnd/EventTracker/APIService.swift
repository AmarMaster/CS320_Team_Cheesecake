//
//  APIService.swift
//  EventTracker
//

import Foundation

class APIService {
    private let baseURL = "http://localhost:3000"
    
    func fetchEvents() async throws -> [EventData] {
        guard let url = URL(string: "\(baseURL)/getEventList") else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AppJSResponse<EventListData>.self, from: data)
        
        if response.data.success {
            return response.data.events
        } else {
            throw APIError.serverError("Failed to fetch events")
        }
    }
    
    func fetchFilteredEvents(
        userID: String? = nil,
        location: (lat: Double, lon: Double)? = nil,
        radius: Int? = nil,
        datetime: Date? = nil,
        twentyoneplus: Bool? = nil,
        cost: Double? = nil
    ) async throws -> [EventData] {
        
        // Use URLComponents instead of concatenating here because convenience
        var components = URLComponents(string: "\(baseURL)/getEventList")!
        var items: [URLQueryItem] = []

        if let userID = userID {
            items.append(URLQueryItem(name: "userID", value: userID))
        }

        if let location = location {
            let locString = "\(location.lat),\(location.lon)"
            items.append(URLQueryItem(name: "location", value: locString))
        }

        if let radius = radius {
            items.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }

        if let datetime = datetime {
            let formatter = DateFormatter()
            // Format is: "YYYY-MM-DDTHH:MM:SS"
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let datetimeString = formatter.string(from: datetime)
            items.append(URLQueryItem(name: "datetime", value: datetimeString))
        }

        if let twentyoneplus = twentyoneplus {
            items.append(URLQueryItem(name: "twentyoneplus", value: twentyoneplus ? "true" : "false"))
        }

        if let cost = cost {
            items.append(URLQueryItem(name: "cost", value: "\(cost)"))
        }
        
        // queryItems added here
        components.queryItems = items

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(AppJSResponse<EventListData>.self, from: data)

        if response.data.success {
            return response.data.events
        } else {
            throw APIError.serverError("Failed to fetch filtered events")
        }
    }
    
    func createEvent(_ event: EventData, token: String) async throws -> EventData {
        guard let url = URL(string: "\(baseURL)/createEvent") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "auth")
        
        let requestBody = CreateEventRequest(data: CreateEventData(userID: "user", event: event), auth: AuthData(jwt: token))
        
        let encoder = JSONEncoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(formatter)
        request.httpBody = try encoder.encode(requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<EventCreateData>.self, from: data)
        
        if response.data.success {
            return response.data.event
        } else {
            throw APIError.serverError("Failed to create event")
        }
    }
}

struct AppJSResponse<T: Codable>: Codable {
    let data: T
}

struct EventListData: Codable {
    let success: Bool
    let events: [EventData]
}

struct EventCreateData: Codable {
    let success: Bool
    let event: EventData
}

struct CreateEventRequest: Codable {
    let data: CreateEventData
    let auth: AuthData
}

struct CreateEventData: Codable {
    let userID: String
    let event: EventData
}

struct AuthData: Codable {
    let jwt: String
}

enum APIError: Error {
    case invalidURL
    case serverError(String)
    case noData
}