//
//  StorageManager.swift
//  TaskList
//
//  Created by Максим Гурков on 03.04.2023.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private var viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    private var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores { storeDescriptio, error in
            if let error = error as NSError? {
                fatalError("Error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Error \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchData(completion: @escaping (Result<[Task], Error>) -> Void) {
        let fetchRequest = Task.fetchRequest()
        
        do {
            let task = try viewContext.fetch(fetchRequest)
            completion(.success(task))
        } catch {
            completion(.failure(error))
        }
    }
    
    func save(_ taskName: String, completion: @escaping (Task) -> Void) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: viewContext) else { return }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: viewContext) as? Task else { return }
        task.title = taskName
        completion(task)
        saveContext()
    }
    
    func delete(task: Task) {
        viewContext.delete(task)
        saveContext()
    }
    
    func edit(task: Task, newTask: String) {
        task.title = newTask
        saveContext()
    }
}
