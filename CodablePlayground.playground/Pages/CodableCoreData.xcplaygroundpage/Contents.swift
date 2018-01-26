//: [Previous](@previous)

import CoreData
import PlaygroundSupport

/*:
 
 If our app persists data on a local database and communicates with a webservice, NSManagedObject can be make to conform to codable protocol. However auto-generated encoding/decoding doesn’t work as in the previous example. Making NSManagedObject conform to Codable protocol must be done manually.

 */

@objc(Page)
class Page: NSManagedObject, Decodable, Managed {
/*:
 
 There are some constraints in this step.
 
 init(from:): is the required initializer for Decodable. According to the Swift documentation, Extensions can add new convenience initializers to a class, but they cannot add new designated initializers or deinitializers to a class. We must conform Decodable in the original class instead of extension
 
 */

    
    @NSManaged var status: String?
    @NSManaged var projects: Set<Project>
    
    enum CodingKeys: String, CodingKey {
        case status = "STATUS"
        case projects
    }
    
    required convenience init(from decoder: Decoder) throws {

/*:

 How to get NSManagedObjectContext in init(from:):?
 We can use userInfo in Decoder. We can pass a NSManagedObjectContext to the init(from:): through userInfo.
 
 */
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError("There's no context") }

        guard let entity = NSEntityDescription.entity(forEntityName: Page.entityName, in: context) else { fatalError("No valid entity") }

/*:
 
 The super class NSManagedObject doesn’t implement the designated initializers, so app will crash once super.init(entity: , insertInto:) is invoked. So we need to leverage self.init(entity: , insertInto:)
 
 */
        
        self.init(entity: entity, insertInto: context)
        
/*:
 
 We can use the decoder for the context:
 
 */

        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        
        if let projectsFromJson  = try container.decodeIfPresent([Project].self, forKey: .projects) {
            self.projects = Set(projectsFromJson)

        }
    }
    
    
}

extension Page: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(status, forKey: .status)
        let proj = Array(projects)
        try container.encode(proj, forKey: .projects)

    }
}

@objc(Project)
class Project: NSManagedObject, Decodable, Managed {
    
     @NSManaged var name: String
     @NSManaged var createdOn: String
     @NSManaged var logo: String
     @NSManaged var projectDescription: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case createdOn = "created-on"
        case logo
        case projectDescription = "description"
    }
    
    required convenience init(from decoder: Decoder) throws {

        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError() }
        guard let entity = NSEntityDescription.entity(forEntityName: Project.entityName, in: context) else { fatalError() }
        
        self.init(entity: entity, insertInto: context)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try container.decodeIfPresent(String.self, forKey: .name)!

        self.createdOn = try container.decodeIfPresent(String.self, forKey: .createdOn)!

        self.logo = try container.decodeIfPresent(String.self, forKey: .logo)!

        self.projectDescription = try container.decodeIfPresent(String.self, forKey: .projectDescription)!

    }
}

extension Project: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(createdOn, forKey: .createdOn)
        try container.encode(logo, forKey: .logo)
        try container.encode(projectDescription, forKey: .projectDescription)
    }
}

/*:
 
  Here we're going to create a NSManagedObject Page object from the JSON file and
  store it in CoreData.
 
 */

createSampleContainer { container in
        
    print ("\n*************")
    print("\nNumber of persistent stores loaded \(container.persistentStoreCoordinator.persistentStores.count)\n")

    
    let context = container.viewContext
    let model = container.managedObjectModel
    
    print("Managed Object Model Entities\n")
    model.entities.forEach { entity in
        print ("Entity name \(entity.name)\n")        
    }
    
    let psc = container.persistentStoreCoordinator
    
    print("Persistent Stores in use:\n")
   
    psc.persistentStores.forEach { store in
        print("\(store.description)\n")
    }
    
    if let jsonData = jsonStringFromAPI.data(using: .utf8) {
        /*:
         
         We create a decoder and pass it the context we want to use
         
         */
        let decoder = JSONDecoder()
        decoder.userInfo[.context] = context
        
        /*:
         
         We can decode the model object from the json file and generate the corresponding NSManagedObject
         models and its relationships.
         
         For the sake of simplicity we'll be storing the created Page object and its two related projects
         and afterwards we'll iterate through the relationship.
         
         */
        
        if let newPage = try? decoder.decode(Page.self, from: jsonData) {
            print("newPage \(String(describing: newPage))")
            
            print("Pending to save \(context.pendingToSave)")
            
            context.saveOrRollback()  //: See other nice methods in NSManagedObjectContext extension
            
            print("Pending to save \(context.pendingToSave)")
            
            newPage.projects.forEach { project in
                guard let project = project as? Project else { return }
                print("Projects info page: \(String(describing: project.name))")
            }
        }
        
    }
}

PlaygroundPage.current.needsIndefiniteExecution = true

//: [Next](@next)
