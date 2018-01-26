import CoreData

public func createSampleContainer(completion: @escaping (NSPersistentContainer) -> ()) {
    let container = NSPersistentContainer(name:"CodableModel")

    print(container.persistentStoreDescriptions.debugDescription)

    container.loadPersistentStores { store, error in
        print("Store URL: \(String(describing: store.url))")
        guard error == nil else { fatalError("Failed to load store: \(String(describing: error))") }
    
        DispatchQueue.main.async {
            completion(container)
        }
    }
}


