//: [Previous](@previous)

/*:
 To encode and decode a custom type, we need to make it Codable.
 
 **Codable Protocol**
 
 A type that can convert itself into and out of an external representation. It is used by the type can be both encoded as well as decoded.
 
 **typealias Codable = Decodable & Encodable**
 
 It includes the methods declared in both Encodable as well as Decodable.
 
 **Encodable Protocol**

 A type that can encode itself to an external representation. It is used by the types that can be encoded.
 It contains a single method:
 encode(to:) — Encodes this value into the given encoder.
 
 **Decodable Protocol**
 
 A type that can decode itself from an external representation. It is used by the types that can be decoded.
 It also contains a single method:
 init(from:) — Creates a new instance by decoding from the given decoder.
*/

import UIKit

struct ProjectPage: Codable {
    
/*:
Codable types are String, Int, Double, Data, URL
 
Array, Dictionary, Optional are Codable if they contain Codable types */

    let status: String?
    let projects: [Project]?
    
/*:
 Codable types can declare a special nested enumeration named CodingKeys that conforms to the CodingKey protocol.
 When this enumeration is present, its cases serve as the authoritative list of properties that must be included
 when instances of a codable type are encoded or decoded.
 
 Omit the properties from CodingKeys if you want to omit them from encoding/decoding process. A property omitted
 from CodingKeys needs a default value.
 
 Provide alternative keys by specifying String as the raw-value type for the CodingKeys enumeration. The string you
 use as a raw value for each enumeration case is the key name used during encoding and decoding
 */

enum CodingKeys: String, CodingKey {
        case status = "STATUS"
        case projects
    }
}

struct Project: Codable {
    
    let name: String
    let createdOn: String
    let logo: String
    let description: String
 
    enum CodingKeys: String, CodingKey {
        case name
        case createdOn = "created-on"
        case logo
        case description
    }
}
    
if let jsonData = jsonStringFromAPI.data(using: .utf8) {
//: JSONDecoder’s decode(_:from:) method returns a value of the codable type you specify, decoded from a JSON object.
    let pageObject = try! JSONDecoder().decode(ProjectPage.self, from: jsonData)
    print ("DECODED OBJECT \(String(describing: pageObject.self))\n")
    
//: Now let's encode pageObject (type is ProjectPage now) with JUST 1 LINE!!!
//: JSONEncoder’s encode(_:) method returns a JSON-encoded representation of the codable type
    let encodedPage = try! JSONEncoder().encode(pageObject)
    print ("ENCODED OBJECT \(String(describing: encodedPage.self))\n")

}
/*:
 There exist scenarios when the structure of your Codable Type differs from the structure of its encoded form
 In that case, you can provide your own custom logic of Encodable and Decodable to define your own encoding and
 decoding logic.
 You need to implement **encode(to:)** and **init(from:)** methods of Encodable and Decodable protocols explicitly.*/

//: [Next](@next)
