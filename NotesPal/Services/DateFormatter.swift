//
//  DateFormatter.swift
//  NotesPal
//
//  Created by Артём Харченко on 20.01.2023.
//

import Foundation

extension Date {
    func format() -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "h:mm a"
            
        } else {
            formatter.dateFormat = "dd/MM/yy"
        }
        return formatter.string(from: self)
    }
}
