//
//  BottomNavBar.swift
//  EventTracker
//

import SwiftUI

struct BottomNavBar: View {
    let fixedName: String
    let fixedEmail: String
    
    var body: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }

            Spacer()
            
            Button(action: {}) {
                Image(systemName: "map")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }
            
            Spacer()
            
            NavigationLink(destination: ProfileView(fixedName: fixedName, fixedEmail: fixedEmail)) {
                Image(systemName: "person")
                    .foregroundColor(.white)
                    .font(.system(size: 30))
            }
        }
        .padding(.horizontal, 70)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            BottomNavBar(fixedName: "Placeholder", fixedEmail: "placeholder@umass.edu")
        }
    }
}
