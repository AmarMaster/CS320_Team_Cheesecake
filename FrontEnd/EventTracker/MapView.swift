//
//  Map.swift
//  EventTracker
//

import SwiftUI
import MapKit

struct MapView: View {
    var fixedName: String
    var fixedEmail: String
    
    @EnvironmentObject var ViewModel: APIViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 42.3757, longitude: -72.5199),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    // Toggles filter menu
    @State private var showFilters = false
    
    // Filter criteria
    @State private var userID: String? = nil
    @State private var filterLocation: CLLocationCoordinate2D? = nil
    @State private var radius: Double? = nil
    @State private var datetime: Date? = nil
    @State private var twentyoneplus: Bool? = nil
    @State private var cost: Double? = nil
    
    @State private var selectedEvent: EventData? = nil

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                EventsMap(region: $region, events: ViewModel.events, selectedEvent: $selectedEvent)
                    .cornerRadius(16)
                    .task {
                        await ViewModel.fetchEvents()
                    }
                
                VStack {
                    // Cool button for filter 
                    Button {
                        withAnimation {
                            showFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }

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
                    .padding(.top, 50)
                
                // If filter is selected
                if showFilters {
                    VStack(alignment: .leading, spacing: 12) {
                        // Toggle for 21+ only events
                        Toggle("21+ Only", isOn: Binding(
                            get: { twentyoneplus ?? false },
                            set: { twentyoneplus = $0 ? true : nil }
                        ))
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        // Filter for events happening at certain time...
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Time: ")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            DatePicker("Date and Time", selection: Binding(
                                get: { datetime ?? Date() },
                                set: { datetime = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Max Cost: $\(Int(cost ?? 0))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            // Slider to select cost
                            Slider(
                                value: Binding(
                                    get: { cost ?? 0 },
                                    set: { cost = $0 > 0 ? $0 : nil }
                                ),
                                in: 0...200,
                                step: 1
                            )
                            .frame(height: 20)
                        }
                        
                        Button("Apply Filters") {
                            Task {
                                await ViewModel.fetchFilteredEvents(
                                    userID: nil,
                                    location: nil,
                                    radius: nil,
                                    datetime: datetime,
                                    twentyoneplus: twentyoneplus,
                                    cost: cost
                                )
                            }
                            withAnimation {
                                showFilters = false
                            }
                        }
                        .padding(.top, 6)
                        .font(.callout)
                    }
                    .padding(10)
                    .background(Color(UIColorFromRGB(0xF0F0F0)))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(maxWidth: 222)
                    .padding(.top, 90)
                    .padding(.trailing, 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                .padding(.vertical, 29)
        }
        .navigationBarHidden(true)
        .background(Color(UIColorFromRGB(0x1B1A1A)))
        .ignoresSafeArea()
        .sheet(item: $selectedEvent) { event in
            EventPage(event: event)
                .presentationDetents([.medium, .large])  
        }
    }
}

// Can also test with a mock APIViewModel that returns mock data 
#Preview {
    NavigationView {
        MapView(fixedName: "Placeholder", fixedEmail: "placeholder@umass.edu")
            .environmentObject(APIViewModel())
    }
}
