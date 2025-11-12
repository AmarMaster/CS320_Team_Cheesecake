//
//  AddEventView.swift
//  EventTracker
//

import SwiftUI
import PhotosUI
import MapKit

struct AddEventView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var manualAddress = ""
    @State private var date = Date()
    @State private var time = Date()
    
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
                                // Title
                                VStack(alignment: .leading, spacing: 10){
                                    Text("Title")
                                        .foregroundColor(.white)
                                        .bold()
                                    TextField("Event Title", text: $title)
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
                                    
                                    // Manual address
                                    TextField("", text: $manualAddress, prompt: Text("Building, Room No.").foregroundColor(.gray))
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
                                
                                // Date + Time pickers
                                DatePicker("Date", selection: $date, displayedComponents: .date)
                                    .bold()
                                    .padding()
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .colorScheme(.dark)
                                
                                DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                                    .bold()
                                    .padding()
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                    .colorScheme(.dark)
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 80)
                        }
                    }
                    
                    VStack {
                        Button(action: {
                            let newEvent = EventData(
                                title: title,
                                description: description,
                                address: manualAddress,
                                location: pickedCoordinate,
                                date: date,
                                time: time
                            )
                            events.append(newEvent)
                            dismiss()
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

                        
                        BottomNavBar()
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    AddEventView(events: .constant([]))
}
