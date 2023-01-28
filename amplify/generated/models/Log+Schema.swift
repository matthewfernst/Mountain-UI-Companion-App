// swiftlint:disable all
import Amplify
import Foundation

extension Log {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case title
    case user
    case createdAt
    case updatedAt
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let log = Log.keys
    
    model.pluralName = "Logs"
    
    model.attributes(
      .primaryKey(fields: [log.id])
    )
    
    model.fields(
      .field(log.id, is: .required, ofType: .string),
      .field(log.title, is: .required, ofType: .string),
      .belongsTo(log.user, is: .optional, ofType: User.self, targetNames: ["userLogbookId"]),
      .field(log.createdAt, is: .optional, isReadOnly: true, ofType: .dateTime),
      .field(log.updatedAt, is: .optional, isReadOnly: true, ofType: .dateTime)
    )
    }
}

extension Log: ModelIdentifiable {
  public typealias IdentifierFormat = ModelIdentifierFormat.Default
  public typealias IdentifierProtocol = DefaultModelIdentifier<Self>
}