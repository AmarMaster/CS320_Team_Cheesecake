//
//  Item.swift
//  EventTracker
//
//  Created by Nguyen Nhat Hong Anh on 10/24/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
