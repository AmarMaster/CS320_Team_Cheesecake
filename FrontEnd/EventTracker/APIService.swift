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
