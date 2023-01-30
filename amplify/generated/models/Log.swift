// swiftlint:disable all
import Amplify
import Foundation

public struct Log: Model {
  public let id: String
  public var title: String
  public var user: User?
  public var createdAt: Temporal.DateTime?
  public var updatedAt: Temporal.DateTime?
  
  public init(id: String = UUID().uuidString,
      title: String,
      user: User? = nil) {
    self.init(id: id,
      title: title,
      user: user,
      createdAt: nil,
      updatedAt: nil)
  }
  internal init(id: String = UUID().uuidString,
      title: String,
      user: User? = nil,
      createdAt: Temporal.DateTime? = nil,
      updatedAt: Temporal.DateTime? = nil) {
      self.id = id
      self.title = title
      self.user = user
      self.createdAt = createdAt
      self.updatedAt = updatedAt
  }
}