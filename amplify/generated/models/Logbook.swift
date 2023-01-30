// swiftlint:disable all
import Amplify
import Foundation

public struct Logbook: Model {
  public let id: String
  public var logs: List<Log>?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      logs: List<Log>? = []) {
    self.init(id: id,
      logs: logs,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      logs: List<Log>? = [],
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.logs = logs
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}