//
//  Persistence.swift
//  MyFinance Tracker
//
//  Created by SerhiiAdmin on 25.11.2024.
//

import Foundation
import CoreData

// A singleton class to manage the Core Data stack.
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    private init() {
        container = NSPersistentContainer(name: "DataNotes")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
}
