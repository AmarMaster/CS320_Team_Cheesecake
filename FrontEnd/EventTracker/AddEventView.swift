//
//  AddEventView.swift
//  EventTracker
//

import SwiftUI
import PhotosUI
import MapKit

struct AddEventView: View {
    var fixedName: String
    var fixedEmail: String
    
    @State private var showError = false
    @State private var canContinue = false
    
    @State private var name = ""
    @State private var description = ""
    @State private var location = ""
    @State private var time = Date()
    @State private var duration = 1
    @State private var details = ""
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var eventImage: UIImage? = nil
    
    @Binding var events: [EventData]
    @Environment(\.dismiss) var dismiss
    
    @State private var pickedCoordinate: CLLocationCoordinate2D? = nil
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Add an Event")
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.top, 30)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 20) {
                                // Name
                                VStack(alignment: .leading, spacing: 10){
                                    Text("Event Name")
                                        .foregroundColor(.white)
                                        .bold()
                                    TextField("Event Name", text: $name)
                                        .padding()
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }

                                // Details
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Details (max 120 chars)")
                                        .foregroundColor(.white)
                                        .bold()
                                    TextField("Brief event details", text: $details)
                                        .padding()
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }
                                
                                // Description
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Description")
                                        .foregroundColor(.white)
                                        .bold()
                                    TextField("Event Description", text: $description, axis: .vertical)
                                        .lineLimit(3, reservesSpace: true)
                                        .padding()
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }
                                
                                // Location Input + Map
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Location")
                                        .foregroundColor(.white)
                                        .bold()
                                    
                                    // Location
                                    TextField("", text: $location, prompt: Text("Building, Room No.").foregroundColor(.gray))
                                        .padding()
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                    
                                    // Map
                                    ZStack(alignment: .topTrailing) {
                                        TappableMap(region: $region, pickedCoordinate: $pickedCoordinate)
                                            .frame(height: 300)
                                            .cornerRadius(16)
                                        
                                        VStack {
                                            Button(action: {
                                                let newLatDelta = max(region.span.latitudeDelta * 0.5, 0.001)
                                                let newLonDelta = max(region.span.longitudeDelta * 0.5, 0.001)
                                                region.span = MKCoordinateSpan(latitudeDelta: newLatDelta, longitudeDelta: newLonDelta)
                                            }) {
                                                Image(systemName: "plus.magnifyingglass")
                                                    .padding()
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                            }
                                            Button(action: {
                                                let newLatDelta = region.span.latitudeDelta * 2
                                                let newLonDelta = region.span.longitudeDelta * 2
                                                region.span = MKCoordinateSpan(latitudeDelta: newLatDelta, longitudeDelta: newLonDelta)
                                            }) {
                                                Image(systemName: "minus.magnifyingglass")
                                                    .padding()
                                                    .foregroundColor(.white)
                                                    .background(Color.black.opacity(0.5))
                                                    .clipShape(Circle())
                                            }
                                        }.padding()
                                    }
                                    
                                    if let coord = pickedCoordinate {
                                        Text("Selected: \(coord.latitude), \(coord.longitude)")
                                            .foregroundColor(.white)
                                            .font(.footnote)
                                    } else {
                                        Text("Pick a location on the map")
                                            .foregroundColor(.white)
                                            .font(.footnote)
                                    }
                                }
                                
                                // Date + Time picker
                                DatePicker("Date & Time", selection: $time, displayedComponents: [.date, .hourAndMinute])
                                    .bold()
                                    .padding()
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .colorScheme(.dark)
                                
                                // Duration picker
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Duration (hours)")
                                        .foregroundColor(.white)
                                        .bold()
                                    Picker("Duration", selection: $duration) {
                                        Text("1 hour").tag(1)
                                        Text("2 hours").tag(2)
                                        Text("3 hours").tag(3)
                                        Text("4 hours").tag(4)
                                        Text("6 hours").tag(6)
                                        Text("8 hours").tag(8)
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .padding()
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 80)
                        }
                    }
                    if showError {
                        Text("All fields are required.")
                            .foregroundColor(.red)
                            .font(.body)
                    }
                    VStack {
                        Button(action: {
                            if (name.isEmpty || details.isEmpty || description.isEmpty || location.isEmpty || pickedCoordinate == nil) {
                                showError = true
                            }
                            else if let coord = pickedCoordinate {
                                showError = false
                                let newEvent = EventData(
                                    name: name,
                                    description: description,
                                    coordinate: coord,
                                    time: time,
                                    duration: duration,
                                    details: details
                                )
                                events.append(newEvent)
                                dismiss()
                            }
                        }) {
                            Text("Add Event")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background( Color(UIColorFromRGB(0xFF5934)))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 29)
                        
                     

                        
                        BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                    }
                }
                .navigationBarHidden(true)
                
            }
        }
    }
}

#Preview {
    AddEventView(
        fixedName: "Placeholder",
        fixedEmail: "placeholder@umass.edu",
        events: .constant([])
    )
}
