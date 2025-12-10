//
//  ProfileView.swift
//  EventTracker
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    let fixedName: String
    let fixedEmail: String
    
    @State private var phoneNumber = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: UIImage? = nil
    @State private var showSettingsSheet = false
    
    @State private var events: [EventData] = [
        EventData(
            name: "Sample Event",
            description: "This is a sample event",
            coordinate: CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711),
            locationString: "UMass Amherst",
            time: Date(),
            durationHours: 2,
            durationMinutes: 0,
            details: "Sample event details",
            adultOnly: false,
            cost: 0,
            owner_id: 1
        )
    ]
    @State private var rsvpEvents: [EventData] = []
    @State private var selectedEventType = 0 // 0: Hosted, 1: RSVP, 2: Favorite
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                // info
                VStack {
                    VStack {
                        HStack {
                            Spacer()
                            
                            // settings button
                            Button(action: {
                                showSettingsSheet = true
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 30))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .sheet(isPresented: $showSettingsSheet) {
                            SettingsView(
                                onLogout: handleLogout,
                                onChangePassword: handleChangePassword,
                                onDeleteAccount: handleDeleteAccount
                            )
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                    
                                    Text(String(fixedName.prefix(1)).uppercased())
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .onChange(of: selectedItem, initial: false) { oldItem, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    profileImage = uiImage
                                }
                            }
                        }
                        
                        // info
                        VStack {
                            Text(fixedName)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack (spacing: 10){
                                Image(systemName: "envelope")
                                Text(fixedEmail)
                            }
                            .foregroundColor(.white)
                            .font(.subheadline)
//                            HStack {
//                                Image(systemName: "phone")
//                                Text("999 999 9999")
//                            }
//                            .foregroundColor(.white)
//                            .font(.subheadline)
                        }
                        
                        // events section header with slider
                        VStack {
                            HStack {
                                Text(["Hosted Events", "RSVP Events", "Favorite Events"][selectedEventType])
                                    .foregroundColor(.white)
                                    .font(.title2)
                                    .bold()
                                
                                Spacer()
                                
                                HStack(spacing: 0) {
                                    Button("Hosted") {
                                        selectedEventType = 0
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(selectedEventType == 0 ? Color(UIColorFromRGB(0xFF5934)) : Color.clear)
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    
                                    Button("RSVP") {
                                        selectedEventType = 1
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(selectedEventType == 1 ? Color(UIColorFromRGB(0xFF5934)) : Color.clear)
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    
                                    Button("Favorite") {
                                        selectedEventType = 2
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(selectedEventType == 2 ? Color(UIColorFromRGB(0xFF5934)) : Color.clear)
                                    .foregroundColor(.white)
                                    .font(.caption)
                                }
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        VStack(spacing: 5) {
                            ForEach(Array(events.enumerated()), id: \.offset) { index, event in
                                NavigationLink(destination: EventInfoView(event: event, fixedName: fixedName, fixedEmail: fixedEmail, events: $events, eventIndex: index)) {
                                    HStack(alignment: .top, spacing: 12) {
                                        // event image
                                        VStack {
                                            if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } else {
                                                RoundedRectangle(cornerRadius: 8)
                                                     .fill(Color.gray.opacity(0.3))
                                                     .frame(width: 100, height: 100)
                                                     .overlay(
                                                         Image(systemName: "photo")
                                                             .foregroundColor(.gray)
                                                             .font(.title3)
                                                     )
                                            }
                                        }.frame(height: 100)
                                     
                                        
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(event.name)
                                                .foregroundColor(.white)
                                                .bold()
                                                .font(.title3)
                                            
                                            eventLocationView(event.locationString)
                                            eventDateView(event.time)
                                            eventTimeView(event.time)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        // Arrow
                                        VStack {
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                            Spacer()
                                        }
                                        .frame(height: 100)
                                    }
                                    .padding()
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .cornerRadius(16)
                                    .padding(.horizontal, 20)
                                }
                                
                                
                            }
                        }
                        
                        Spacer()
                        // add event button
                        VStack {
                            NavigationLink(destination: AddEventView(
                                fixedName: fixedName,
                                fixedEmail: fixedEmail,
                                events: $events
                            )) {
                                Text("+ Add an Event")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColorFromRGB(0xFF5934)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }.padding(.horizontal, 20)
                                .padding(.vertical, 29)
                        }
                    
                    }
                    Spacer()
                    BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)

                    }
                .navigationBarHidden(true)

            }
        }

    }
    
    private func eventLocationView(_ locationText: String) -> some View {
        HStack {
            Image(systemName: "mappin.and.ellipse")
            Text(locationText)
        }
        .foregroundColor(.white)
        .font(.subheadline)
    }
    
    private func eventCoordinateView(_ location: EventLocation) -> some View {
        HStack {
            Image(systemName: "location")
            Text("\(location.latitude, specifier: "%.4f"), \(location.longitude, specifier: "%.4f")")
        }
        .foregroundColor(.white)
        .font(.subheadline)
    }
    
    private func eventDateView(_ time: Date) -> some View {
        HStack {
            Image(systemName: "calendar")
            Text(time.formatted(.dateTime.month().day().year()))
        }
        .foregroundColor(.white)
        .font(.subheadline)
    }
    
    private func eventTimeView(_ time: Date) -> some View {
        HStack {
            Image(systemName: "clock")
            Text(time.formatted(.dateTime.hour().minute()))
        }
        .foregroundColor(.white)
        .font(.subheadline)
    }
    
    private func handleLogout() {
        // Handle logout logic
    }
    
    private func handleChangePassword(_ newPassword: String) {
        // Handle change password logic
    }
    
    private func handleDeleteAccount() {
        // Handle delete account logic
    }
}

#Preview {
    ProfileView(fixedName: "Your Name", fixedEmail: "email@umass.edu")
}
