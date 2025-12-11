//
//  APIService.swift
//  EventTracker
//

import Foundation

class UserSession: ObservableObject {
    @Published var currentUserId: String?
    @Published var currentUsername: String?
    @Published var jwtToken: String?
    @Published var isLoggedIn: Bool = false
    @Published var selectedEventDetails: EventData? = nil // Details for a single event
    
    static let shared = UserSession()
    
    private init() {}
    
    func login(userId: String, username: String, token: String) {
        currentUserId = userId
        currentUsername = username
        jwtToken = token
        isLoggedIn = true
    }
    
    func logout() {
        currentUserId = nil
        currentUsername = nil
        jwtToken = nil
        isLoggedIn = false
    }
}

class APIService {
    private let baseURL = "http://localhost:3000"
    
    func fetchEvents() async throws -> [EventData] {
        // TODO:
        // Properly insert the current coordinates and the desired radius
        guard let url = URL(string: "\(baseURL)/getEventList?location=3.0,3.0&radius=3000000000.0") else {
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
        
        guard let userID = UserSession.shared.currentUserId,
              let jwt = UserSession.shared.jwtToken else {
            print("DEBUG: User not logged in - userID: \(UserSession.shared.currentUserId ?? "nil"), jwt: \(UserSession.shared.jwtToken ?? "nil")")
            throw APIError.serverError("User not logged in")
        }
        
        print("DEBUG: Creating event with userID: \(userID), jwt: \(jwt.prefix(20))...")
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let formatter = ISO8601DateFormatter()
        
        let requestBody = [
            "data": [
                "userID": userID,
                "event": [
                    "name": event.name,
                    "location": [
                        "latitude": event.location.latitude,
                        "longitude": event.location.longitude
                    ],
                    "time": formatter.string(from: event.time),
                    "duration": event.durationHours * 3600 + event.durationMinutes * 60,
                    "details": event.details,
                    "description": event.description
                ] as [String: Any]
            ] as [String: Any],
            "auth": ["jwt": jwt]
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse {
            print("DEBUG: HTTP Status: \(httpResponse.statusCode)")
        }
        
        let response = try JSONDecoder().decode(AppJSResponse<EventCreateData>.self, from: data)
        
        if response.data.success {
            return response.data.event
        } else {
            throw APIError.serverError("Failed to create event")
        }
    }
    
    func fetchEventDetails(eventID: String) async throws -> EventData {
        var components = URLComponents(string: "\(baseURL)/getEventData")!
        components.queryItems = [
            URLQueryItem(name: "eventID", value: "\(eventID)")
        ]
        
        guard let url = components.url else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let response = try decoder.decode(AppJSResponse<EventGetData>.self, from: data)
        
        if response.data.success {
            return response.data.event
        } else {
            throw APIError.serverError("Failed to fetch events")
        }
    }
    // ------
    
    func getAllFriends(username: String) async throws -> [String] {
        guard let url = URL(string: "\(baseURL)/getAllFriends") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendsData>.self, from: data)
        
        if response.data.success {
            return response.data.friends
        } else {
            throw APIError.serverError("Failed to get friends")
        }
    }
    
    func addFriend(username: String, friendUsername: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/addFriend") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username, "friendUsername": friendUsername]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendActionData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    func removeFriend(username: String, friendUsername: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/removeFriend") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username, "friendUsername": friendUsername]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendActionData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    func login(username: String, password: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username, "password": password]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<LoginData>.self, from: data)
        
        if response.data.success {
            let userId = extractUserIdFromJWT(response.data.jwt) ?? "1"
            UserSession.shared.login(userId: userId, username: username, token: response.data.jwt)
            return LoginResponse(success: true, message: response.data.message, jwt: response.data.jwt)
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    private func extractUserIdFromJWT(_ token: String) -> String? {
        let parts = token.components(separatedBy: ".")
        guard parts.count == 3 else { return nil }
        
        var payload = parts[1]
        while payload.count % 4 != 0 {
            payload += "="
        }
        
        guard let data = Data(base64Encoded: payload),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let userId = json["userId"] as? Int else {
            return nil
        }
        
        return String(userId)
    }
    
    func createAccount(name: String, password: String, email: String) async throws -> LoginResponse {
        guard let url = URL(string: "\(baseURL)/createAccount") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["name": name, "password": password, "email": email]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<LoginData>.self, from: data)
        
        if response.data.success {
            let userId = extractUserIdFromJWT(response.data.jwt) ?? "1"
            UserSession.shared.login(userId: userId, username: name, token: response.data.jwt)
            return LoginResponse(success: true, message: response.data.message, jwt: response.data.jwt)
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    func changePassword(username: String, password: String, newPassword: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/changePassword") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username, "password": password, "newPassword": newPassword]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<PasswordChangeData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    func deleteAccount(username: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/deleteAccount") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<AccountDeleteData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    func getFriendEvents(username: String, friendUsername: String) async throws -> [EventData] {
        guard let url = URL(string: "\(baseURL)/getFriendEvents") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": username, "friendUsername": friendUsername]]
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendEventsData>.self, from: data)
        
        if response.data.success {
            return response.data.events
        } else {
            throw APIError.serverError("Failed to get friend events")
        }
    }
    
    func updateEvent(_ event: EventData, token: String) async throws -> EventData {
        guard let url = URL(string: "\(baseURL)/changeEvent") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userID = UserSession.shared.currentUserId ?? "1"
        let formatter = ISO8601DateFormatter()
        
        let requestBody = [
            "data": [
                "userID": userID,
                "eventID": String(event.id ?? 0),
                "event": [
                    "name": event.name,
                    "location": [
                        "latitude": event.location.latitude,
                        "longitude": event.location.longitude
                    ],
                    "time": formatter.string(from: event.time),
                    "duration": event.durationHours * 3600 + event.durationMinutes * 60,
                    "details": event.details,
                    "description": event.description
                ] as [String: Any]
            ] as [String: Any],
            "auth": ["jwt": UserSession.shared.jwtToken ?? ""]
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<EventCreateData>.self, from: data)
        
        if response.data.success {
            return response.data.event
        } else {
            throw APIError.serverError("Failed to update event")
        }
    }
    
    func deleteEvent(eventID: String, token: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/deleteEvent") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userID = UserSession.shared.currentUserId ?? "1"
        
        let requestBody = [
            "data": [
                "userID": userID,
                "eventID": eventID
            ],
            "auth": ["jwt": UserSession.shared.jwtToken ?? ""]
        ] as [String: Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<DeleteEventData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }
    
    func toggleRSVP(eventID: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/toggleRSVP") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let userID = UserSession.shared.currentUserId,
              let jwt = UserSession.shared.jwtToken else {
            throw APIError.serverError("User not logged in")
        }
        
        let requestBody: [String: Any] = [
            "data": [
                "userID": userID,
                "eventID": eventID,
                "rsvpStatus": 1 // Or your logic for RSVP status
            ],
            "auth": [
                "jwt": jwt
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendActionData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }

    func toggleFavorite(eventID: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/toggleFavorite") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let userID = UserSession.shared.currentUserId,
              let jwt = UserSession.shared.jwtToken else {
            throw APIError.serverError("User not logged in")
        }
        
        let requestBody: [String: Any] = [
            "data": [
                "userID": userID,
                "eventID": eventID
            ],
            "auth": [
                "jwt": jwt
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendActionData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
        }
    }

    func toggleHosted(eventID: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/toggleHosted") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let userID = UserSession.shared.currentUserId,
              let jwt = UserSession.shared.jwtToken else {
            throw APIError.serverError("User not logged in")
        }
        
        let requestBody: [String: Any] = [
            "data": [
                "userID": userID,
                "eventID": eventID
            ],
            "auth": [
                "jwt": jwt
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(AppJSResponse<FriendActionData>.self, from: data)
        
        if response.data.success {
            return response.data.message
        } else {
            throw APIError.serverError(response.data.message)
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

struct EventGetData: Codable {
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

struct FriendsData: Codable {
    let success: Bool
    let friends: [String]
}

struct FriendActionData: Codable {
    let success: Bool
    let message: String
}

struct LoginData: Codable {
    let success: Bool
    let message: String
    let jwt: String
}

struct LoginResponse {
    let success: Bool
    let message: String
    let jwt: String
}

struct PasswordChangeData: Codable {
    let success: Bool
    let message: String
}

struct AccountDeleteData: Codable {
    let success: Bool
    let message: String
}

struct FriendEventsData: Codable {
    let success: Bool
    let events: [EventData]
}

struct DeleteEventData: Codable {
    let success: Bool
    let message: String
}

enum APIError: Error {
    case invalidURL
    case serverError(String)
    case noData
}
