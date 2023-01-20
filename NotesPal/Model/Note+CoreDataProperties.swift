//
//  Note+CoreDataProperties.swift
//  NotesPal
//
//  Created by Артём Харченко on 20.01.2023.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var id: UUID!
    @NSManaged public var text: String!
    @NSManaged public var lastUpdated: Date!

}

extension Note : Identifiable {

}
