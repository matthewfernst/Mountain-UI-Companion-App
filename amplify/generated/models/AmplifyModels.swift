// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "fc5f5e5208795f1e602f14946e818e65"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: Logbook.self)
    ModelRegistry.register(modelType: Log.self)
  }
}