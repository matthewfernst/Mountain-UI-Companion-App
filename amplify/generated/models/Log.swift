// swiftlint:disable all
import Amplify
import Foundation

public struct Log: Model {
  public let id: String
  public var logbook: Logbook?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      logbook: Logbook? = nil) {
    self.init(id: id,
      logbook: logbook,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      logbook: Logbook? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.logbook = logbook
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}