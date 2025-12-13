//
//  EditEventView.swift
//  EventTracker
//

import SwiftUI
import PhotosUI
import MapKit

struct EditEventView: View {
    var fixedName: String
    var fixedEmail: String
    
    @State private var showError = false
    @State private var canContinue = false
    
    @State private var name: String
    @State private var description: String
    @State private var location: String
    @State private var time: Date
    @State private var durationHours: Int
    @State private var durationMinutes: Int
    @State private var details: String
    @State private var twentyoneplus = false
    @State private var cost: Double = 0
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var eventImage: UIImage?
    
    @Binding var events: [EventData]
    @Environment(\.dismiss) var dismiss
    @StateObject private var apiViewModel = APIViewModel()
    @ObservedObject private var userSession = UserSession.shared
    
    @State private var pickedCoordinate: CLLocationCoordinate2D?
    @State private var region: MKCoordinateRegion
    
    let eventIndex: Int
    
    init(fixedName: String, fixedEmail: String, events: Binding<[EventData]>, eventIndex: Int) {
        self.fixedName = fixedName
        self.fixedEmail = fixedEmail
        self._events = events
        self.eventIndex = eventIndex
        
        let event = events.wrappedValue[eventIndex]
        self._name = State(initialValue: event.name)
        self._description = State(initialValue: event.description)
        self._location = State(initialValue: event.locationString)
        self._time = State(initialValue: event.time)
        self._durationHours = State(initialValue: event.durationHours)
        self._durationMinutes = State(initialValue: event.durationMinutes)
        self._details = State(initialValue: event.details)
        self._twentyoneplus = State(initialValue: event.adultOnly)
        self._cost = State(initialValue: event.cost)
        self._pickedCoordinate = State(initialValue: CLLocationCoordinate2D(latitude: event.location.latitude, longitude: event.location.longitude))
        self._region = State(initialValue: MKCoordinateRegion(
            center: event.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        
        if let imageData = event.imageData {
            self._eventImage = State(initialValue: UIImage(data: imageData))
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Edit Event")
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
                                
                                // image
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Event Image (Optional)")
                                        .foregroundColor(.white)
                                        .bold()
                                    
                                    PhotosPicker(selection: $selectedItem, matching: .images) {
                                        HStack {
                                            if let eventImage {
                                                Image(uiImage: eventImage)
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                            } else {
                                                Image(systemName: "photo")
                                                    .foregroundColor(.gray)
                                                    .font(.title2)
                                            }
                                            
                                            Text(eventImage == nil ? "Add Image" : "Change Image")
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color(UIColorFromRGB(0x312F2F)))
                                        .cornerRadius(16)
                                    }
                                    .onChange(of: selectedItem, initial: false) { oldItem, newItem in
                                        Task {
                                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                                               let uiImage = UIImage(data: data) {
                                                eventImage = uiImage
                                            }
                                        }
                                    }
                                }
                                
                                // Location Input + Map
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Location")
                                        .foregroundColor(.white)
                                        .bold()
                                    
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
                                    Text("Duration")
                                        .foregroundColor(.white)
                                        .bold()
                                    HStack {
                                        Picker("Hours", selection: $durationHours) {
                                            ForEach(0...12, id: \.self) { hour in
                                                Text("\(hour)h").tag(hour)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 240)
                                        
                                        Picker("Minutes", selection: $durationMinutes) {
                                            ForEach([0, 15, 30, 45], id: \.self) { minute in
                                                Text("\(minute)m").tag(minute)
                                            }
                                        }
                                        .pickerStyle(WheelPickerStyle())
                                        .frame(width: 80)
                                    }
                                    .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(16)
                                .colorScheme(.dark)
                                
                                // 21+ toggle
                                HStack {
                                    Text("21+ Only")
                                        .foregroundColor(.white)
                                        .bold()
                                    Spacer()
                                    Toggle("", isOn: $twentyoneplus)
                                        .toggleStyle(SwitchToggleStyle(tint: Color(UIColorFromRGB(0xFF5934))))
                                }
                                .padding()
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(16)
                                
                                // cost slider
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("Cost: $\(Int(cost))")
                                            .foregroundColor(.white)
                                            .bold()
                                        Spacer()
                                    }
                                    Slider(value: $cost, in: 0...200, step: 1)
                                        .accentColor(Color(UIColorFromRGB(0xFF5934)))
                                }
                                .padding()
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .cornerRadius(16)
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
                            guard let eventId = events[eventIndex].id, eventId > 0 else {
                                showError = true
                                return
                            }
                            
                            if name.isEmpty || details.isEmpty || description.isEmpty || location.isEmpty || pickedCoordinate == nil {
                                showError = true
                            } else if let coord = pickedCoordinate {
                                showError = false
                                let imageData = eventImage?.jpegData(compressionQuality: 0.8)
                                let updatedEvent = EventData(
                                    id: events[eventIndex].id,
                                    name: name,
                                    description: description,
                                    coordinate: coord,
                                    locationString: location,
                                    time: time,
                                    durationHours: durationHours,
                                    durationMinutes: durationMinutes,
                                    details: details,
                                    adultOnly: twentyoneplus,
                                    cost: cost,
                                    owner_id: events[eventIndex].owner_id,
                                    imageData: imageData
                                )
                                
                                Task {
                                    do {
                                        let token = userSession.jwtToken ?? ""
                                        let updated = try await APIService().updateEvent(updatedEvent, token: token)
                                        if eventIndex < events.count {
                                            events[eventIndex] = updated
                                        }
                                        dismiss()
                                    } catch {
                                        print("Error updating event: \(error)")
                                        showError = true
                                    }
                                }
                            }
                        }) {
                            Text("Update Event")
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
        .onAppear {
            // Ensure pickedCoordinate is set from the existing event
            if pickedCoordinate == nil {
                pickedCoordinate = CLLocationCoordinate2D(latitude: events[eventIndex].location.latitude, longitude: events[eventIndex].location.longitude)
            }
        }
    }
}

#Preview {
    EditEventView(
        fixedName: "Placeholder",
        fixedEmail: "placeholder@umass.edu",
        events: .constant([EventData(
            name: "Sample Event",
            description: "Sample description",
            coordinate: CLLocationCoordinate2D(latitude: 42.391155, longitude: -72.526711),
            locationString: "Sample Location",
            time: Date(),
            durationHours: 2,
            durationMinutes: 0,
            details: "Sample details",
            imageData: nil
        )]),
        eventIndex: 0
    )
}
