//
//  FriendProfileView.swift
//  EventTracker
//

import SwiftUI
import CoreLocation

struct FriendProfileView: View {
    let friendUsername: String
    let fixedName: String
    let fixedEmail: String
    
    @State private var events: [EventData] = []
    @State private var isFriend = true
    @State private var isLoading = false
    @State private var showFeedback = false
    @State private var feedbackMessage = ""
    @State private var isSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    VStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Text(String(friendUsername.prefix(1)))
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            )
                        
                        Text(friendUsername)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Button(action: {
                            if isFriend {
                                removeFriend()
                            } else {
                                addFriend()
                            }
                        }) {
                            Text(isLoading ? "Loading..." : (isFriend ? "Remove Friend" : "Add Friend"))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(isLoading ? Color.gray : (isFriend ? Color.red : Color(UIColorFromRGB(0xFF5934))))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .disabled(isLoading)
                        .padding(.top, 10)
                        
                        if showFeedback {
                            Text(feedbackMessage)
                                .foregroundColor(isSuccess ? .green : .red)
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 5)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Friend's events
                    VStack {
                        Text("\(friendUsername)'s Events")
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .padding(.leading, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 30)
                    
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(events) { event in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(event.name)
                                        .foregroundColor(.white)
                                        .bold()
                                        .font(.title3)
                                    
                                    HStack {
                                        Image(systemName: "mappin.and.ellipse")
                                        Text("\(event.location.latitude, specifier: "%.4f"), \(event.location.longitude, specifier: "%.4f")")
                                    }
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text(event.time.formatted(.dateTime.month().day().year()))
                                    }
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                        Text(event.time.formatted(.dateTime.hour().minute()))
                                    }
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                                }
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(16)
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    Spacer()
                    BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            events = [
                EventData(
                    name: "Sample Event 1",
                    description: "This is an event saved by \(friendUsername)",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3868, longitude: -72.5301),
                    locationString: "Campus Center, Room 101",
                    time: Date(),
                    duration: 120,
                    details: "Friend's saved event"
                ),
                EventData(
                    name: "Sample Event 2",
                    description: "Another event in \(friendUsername)'s list",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3900, longitude: -72.5280),
                    locationString: "Student Union, Room 205",
                    time: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    duration: 90,
                    details: "Another saved event"
                )
            ]
        }
    }
    
    private func addFriend() {
        isLoading = true
        showFeedback = false
        
        guard let url = URL(string: "http://localhost:3000/addFriend") else {
            showError("Invalid server URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": fixedName, "friendUsername": friendUsername]]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            showError("Failed to encode request.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                handleResponse(data: data, error: error, successAction: {
                    isFriend = true
                })
            }
        }.resume()
    }
    
    private func removeFriend() {
        isLoading = true
        showFeedback = false
        
        guard let url = URL(string: "http://localhost:3000/removeFriend") else {
            showError("Invalid server URL.")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["data": ["username": fixedName, "friendUsername": friendUsername]]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            showError("Failed to encode request.")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                handleResponse(data: data, error: error, successAction: {
                    isFriend = false
                })
            }
        }.resume()
    }
    
    private func handleResponse(data: Data?, error: Error?, successAction: @escaping () -> Void) {
        isLoading = false
        
        if let error = error {
            showError("Network error: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else {
            showError("No response from server.")
            return
        }
        
        // Debug: Print raw response
        if let responseString = String(data: data, encoding: .utf8) {
            print("Backend response: \(responseString)")
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["data"] as? [String: Any],
               let success = responseData["success"] as? Bool,
               let message = responseData["message"] as? String {
                
                feedbackMessage = message
                isSuccess = success
                
                if success {
                    successAction()
                }
            } else {
                showError("Invalid response format.")
                return
            }
        } catch {
            showError("Failed to parse response.")
            return
        }
        
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showFeedback = false
        }
    }
    
    private func showError(_ message: String) {
        feedbackMessage = message
        isSuccess = false
        showFeedback = true
        isLoading = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showFeedback = false
        }
    }
}

#Preview {
    FriendProfileView(friendUsername: "Friend1", fixedName: "Your Name", fixedEmail: "email@umass.edu")
}
