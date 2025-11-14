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
            }
            

            BottomNavBar(fixedName: fixedName, fixedEmail: fixedEmail)
                .padding(.vertical, 29)
            Spacer()
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
