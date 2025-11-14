//
//  EventPage.swift
//  EventTracker
//

import SwiftUI

struct EventPage: View {
    var event: EventData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text(event.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Description:")
                    .font(.headline)
                Text(event.description)
                    .font(.body)

                Text("Time: \(event.time.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)

                Text("Duration: \(event.duration) minutes")
                    .font(.subheadline)

                Text("Details:")
                    .font(.headline)
                Text(event.details)
                    .font(.body)

                Spacer()
            }
            .padding()
        }
    }
}