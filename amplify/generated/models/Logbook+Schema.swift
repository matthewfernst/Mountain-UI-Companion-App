// swiftlint:disable all
import Amplify
import Foundation

extension Logbook {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case logs
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let logbook = Logbook.keys
    
    model.pluralName = "Logbooks"
    
    model.attributes(
      .primaryKey(fields: [logbook.id])
    )
    
    model.fields(
      .field(logbook.id, is: .required, ofType: .string),
      .hasMany(logbook.logs, is: .optional, ofType: Log.self, associatedWith: Log.keys.logbook),
      .field(logbook.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(logbook.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Logbook: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}