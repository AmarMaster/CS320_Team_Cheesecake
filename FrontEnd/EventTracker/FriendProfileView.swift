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
    private let apiService = APIService()
    
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
                            ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                                NavigationLink(destination: EventInfoView(event: event, fixedName: fixedName, fixedEmail: fixedEmail, events: .constant(events), eventIndex: index)) {
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
                    }
                    
                    Spacer()
                    BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            getFriendEvents()
        }
    }
    
    private func addFriend() {
        isLoading = true
        showFeedback = false
        
        Task {
            do {
                let message = try await apiService.addFriend(username: fixedName, friendUsername: friendUsername)
                await MainActor.run {
                    feedbackMessage = message
                    isSuccess = true
                    isFriend = true
                    isLoading = false
                    showFeedback = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showFeedback = false
                    }
                }
            } catch {
                await MainActor.run {
                    showError("Failed to add friend.")
                }
            }
        }
    }
    
    private func removeFriend() {
        isLoading = true
        showFeedback = false
        
        Task {
            do {
                let message = try await apiService.removeFriend(username: fixedName, friendUsername: friendUsername)
                await MainActor.run {
                    feedbackMessage = message
                    isSuccess = true
                    isFriend = false
                    isLoading = false
                    showFeedback = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        showFeedback = false
                    }
                }
            } catch {
                await MainActor.run {
                    showError("Failed to remove friend.")
                }
            }
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
    
    private func getFriendEvents() {
        Task {
            do {
                let friendEvents = try await apiService.getFriendEvents(username: fixedName, friendUsername: friendUsername)
                await MainActor.run {
                    events = friendEvents
                }
            } catch {
                
            }
        }
    }
}

#Preview {
    FriendProfileView(friendUsername: "Friend1", fixedName: "Your Name", fixedEmail: "email@umass.edu")
}
