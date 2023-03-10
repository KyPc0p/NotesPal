//
//  StorageManger.swift
//  NotesPal
//
//  Created by Артём Харченко on 19.01.2023.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }

    // MARK: - CRUD
    func read(completion: (Result<[Note], Error>) -> Void) { //read
        let fetchRequest = Note.fetchRequest()
        
        do {
            let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            let notes = try viewContext.fetch(fetchRequest)
            completion(.success(notes))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func create(with text: String = "") -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.text = text
        note.lastUpdated = Date()
        saveContext()
        return note
    }
    
    func delete(_ note: Note) {
        viewContext.delete(note)
        saveContext()
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
