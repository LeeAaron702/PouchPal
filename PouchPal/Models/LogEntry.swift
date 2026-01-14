//
//  LogEntry.swift
//  PouchPal
//
//  Created by Lee Seaver on 1/13/26.
//

import Foundation
import SwiftData

@Model
final class LogEntry {
    var id: UUID
    var timestamp: Date
    var quantity: Int
    var source: String?
    var note: String?
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        quantity: Int = 1,
        source: String? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.quantity = quantity
        self.source = source
        self.note = note
    }
}

// MARK: - Computed Properties
extension LogEntry {
    var dayString: String {
        timestamp.formatted(date: .abbreviated, time: .omitted)
    }
    
    var timeString: String {
        timestamp.formatted(date: .omitted, time: .shortened)
    }
}
