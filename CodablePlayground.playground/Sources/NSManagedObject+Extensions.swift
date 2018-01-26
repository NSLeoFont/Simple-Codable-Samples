
import CoreData

public protocol Managed: class {
    static var entityName: String { get }
}

public extension Managed where Self: NSManagedObject {
    public static var entityName: String { return entity().name! }
}


public extension CodingUserInfoKey {
    public static let context = CodingUserInfoKey(rawValue: "context")!
}

public extension NSManagedObjectContext {
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            print ("Saving")
         
            return true
        } catch {
            rollback()
            print ("Rolling Back")
            return false
        }
    }
    
    public func performChanges(block: @escaping () -> ()) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
    
    public var pendingToSave: Int {
       return self.insertedObjects.count
    }
}
