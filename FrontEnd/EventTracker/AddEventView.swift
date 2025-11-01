//
//  AddEventView.swift
//  EventTracker
//

import SwiftUI
import PhotosUI

struct AddEventView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var time = Date()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var eventImage: UIImage? = nil
    
    @Binding var events: [EventData]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColorFromRGB(0x1B1A1A)).ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Add an Event")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 30)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 20) {
                        // event image
                        
                        // info fields
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
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Location")
                                .foregroundColor(.white)
                                .bold()
                            TextField("Event Location", text: $location)
                                .padding()
                                .background(Color(UIColorFromRGB(0x312F2F)))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                        
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
                    
                    Spacer()
                    
                    // Save button
                    Button(action: {
                        let newEvent = EventData(title: title, description: description, location: location, date: date, time: time)
                        events.append(newEvent)
                        dismiss()
                    }) {
                        Text("Add Event")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColorFromRGB(0xFF5934)))
                            .foregroundColor(.white)
                            .cornerRadius(16)
                    }.padding(.horizontal, 20)
                        .padding(.vertical, 29)
                        
                    BottomNavBar()
                }
                .navigationBarHidden(true)


            }
        }

    }
}

#Preview {
    AddEventView(events: .constant([]))
}
