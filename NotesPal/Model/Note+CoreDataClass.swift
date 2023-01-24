//
//  Note+CoreDataClass.swift
//  NotesPal
//
//  Created by Артём Харченко on 20.01.2023.
//
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    var title: String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines).first ?? ""
    }
    
    var titleDescription: String {
        var lines = text.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .newlines)
        lines.removeFirst()
        return "\(lastUpdated.format() ) \(lines.first ?? "")" 
    }
}
