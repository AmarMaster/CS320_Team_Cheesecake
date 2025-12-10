//
//  FriendProfileView.swift
//  EventTracker
//

import SwiftUI
import CoreLocation

struct FriendProfileView: View {
    let friendName: String
    let fixedName: String
    let fixedEmail: String
    
    @State private var events: [EventData] = []
    @State private var isFriend = true
    
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
                                Text(String(friendName.prefix(1)))
                                    .foregroundColor(.white)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                            )
                        
                        Text(friendName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 10)
                        
                        Button(action: {
                            isFriend.toggle()
                        }) {
                            Text(isFriend ? "Remove Friend" : "Add Friend")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(isFriend ? Color.red : Color(UIColorFromRGB(0xFF5934)))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.top, 20)
                    
                    // Friend's events
                    VStack {
                        Text("\(friendName)'s Events")
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
                    description: "This is an event saved by \(friendName)",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3868, longitude: -72.5301),
                    locationString: "Campus Center, Room 101",
                    time: Date(),
                    duration: 120,
                    details: "Friend's saved event"
                ),
                EventData(
                    name: "Sample Event 2",
                    description: "Another event in \(friendName)'s list",
                    coordinate: CLLocationCoordinate2D(latitude: 42.3900, longitude: -72.5280),
                    locationString: "Student Union, Room 205",
                    time: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
                    duration: 90,
                    details: "Another saved event"
                )
            ]
        }
    }
}

#Preview {
    FriendProfileView(friendName: "Friend1", fixedName: "Your Name", fixedEmail: "email@umass.edu")
}
