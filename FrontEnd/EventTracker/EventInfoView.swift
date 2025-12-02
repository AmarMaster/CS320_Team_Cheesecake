//
//  EventInfoView.swift
//  EventTracker
//

import SwiftUI
import MapKit

struct EventInfoView: View {
    let event: EventData
    let fixedName: String
    let fixedEmail: String
    @Binding var events: [EventData]
    let eventIndex: Int
    
    @State private var region: MKCoordinateRegion
    
    
    init(event: EventData, fixedName: String, fixedEmail: String, events: Binding<[EventData]>, eventIndex: Int) {
        self.event = event
        self.fixedName = fixedName
        self.fixedEmail = fixedEmail
        self._events = events
        self.eventIndex = eventIndex
        self._region = State(initialValue: MKCoordinateRegion(
            center: event.coordinate ?? CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text(event.name)
                                .font(.title)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.top, 30)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 20) {
                                // Details
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Details")
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(event.details)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }
                                
                                // Description
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Description")
                                        .foregroundColor(.white)
                                        .bold()
                                    Text(event.description)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                }
                                
                                // Image
                                if let imageData = event.imageData, let uiImage = UIImage(data: imageData) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Event Image")
                                            .foregroundColor(.white)
                                            .bold()
                                        
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxHeight: 200)
                                            .cornerRadius(16)
                                    }
                                }
                                
                                // Location
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Location")
                                        .foregroundColor(.white)
                                        .bold()
                                    
                                    Text(event.locationString)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                    
                                    // Map
                                    Map(coordinateRegion: .constant(region), annotationItems: [event]) { event in
                                        MapAnnotation(coordinate: event.coordinate ?? CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711)) {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title)
                                        }
                                    }
                                    .frame(height: 300)
                                    .cornerRadius(16)
                                }
                                
                                // Date
                                HStack(spacing: 10) {
                                    Text("Date")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Text(event.time.formatted(.dateTime.weekday().month().day().year()))
                                        
                                }.padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                
                                // Time
                                HStack(spacing: 10) {
                                    Text("Time")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Text(event.time.formatted(.dateTime.hour().minute()))
                                        
                                }.padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                
                                // Duration
                                HStack() {
                                    Text("Duration")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Text("\(event.duration) hour\(event.duration == 1 ? "" : "s")")
                                        
                                }.padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(UIColorFromRGB(0x312F2F)))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                                
                                // 21+ Only
                                HStack {
                                    Text("21+ Only")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Text(event.adultOnly ? "Yes" : "No")
                                    
                                }.padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                
                                // Cost
                                HStack {
                                    Text("Cost")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Text(event.cost == 0 ? "Free" : "$\(Int(event.cost))")
                                        
                                }.padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                            
                                
   
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 80)
                        }
                    }
                    
                    VStack(spacing: 15) {
                        
                        // rsvp
                        Button(action: {
                            
                        }) {
                            Text("RSVP")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColorFromRGB(0xFF5934)))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 15)
                        
                        
                        // edit
                        NavigationLink(destination: EditEventView(fixedName: fixedName, fixedEmail: fixedEmail, events: $events, eventIndex: eventIndex)) {
                            Text("Edit Event")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(UIColorFromRGB(0xFF5934)))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 29)
                        
                        BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                    }
                }
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    let sampleEvent = EventData(
        name: "Sample Event",
        description: "This is a sample event description",
        coordinate: CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711),
        locationString: "Sample Location",
        time: Date(),
        duration: 2,
        details: "Sample details",
        imageData: nil
    )
    
    return EventInfoView(
        event: sampleEvent,
        fixedName: "Your Name",
        fixedEmail: "email@umass.edu",
        events: .constant([sampleEvent]),
        eventIndex: 0
    )
}
