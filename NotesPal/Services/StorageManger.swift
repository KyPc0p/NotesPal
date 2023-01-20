//
//  StorageManger.swift
//  NotesPal
//
//  Created by Артём Харченко on 19.01.2023.
//

import CoreData

class StorageManager {
    static let shared = StorageManager()
    
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
    func fetchNotes() -> [Note] { //read
        let request = Note.fetchRequest()
        let sortDescriptor = NSSortDescriptor(keyPath: \Note.lastUpdated, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        return (try? viewContext.fetch(request)) ?? [] //обработать ошибку
    }
    
    func createNote() -> Note {
        let note = Note(context: viewContext)
        note.id = UUID()
        note.text = ""
        note.lastUpdated = Date()
        saveContext()
        return note
    }
    
    func update(){
        saveContext()
    }
    
    func deleteNote(_ note: Note){
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
