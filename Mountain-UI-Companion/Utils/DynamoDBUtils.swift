//
//  DynamoDBUtils.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/12/23.
//

import Foundation
import AWSDynamoDB
import ClientRuntime

struct DynamoDBUtils {
    static let usersTable = "mountain-ui-app-users"
    static let dynamoDBClient = try! DynamoDBClient(region: "us-west-2")
    
    static func putDynamoDBItem(uuid: String, name: String, email: String, profilePictureURL: String) async {
        let itemValues = [
            "uuid": DynamoDBClientTypes.AttributeValue.s(uuid),
            "email": DynamoDBClientTypes.AttributeValue.s(email),
            "name": DynamoDBClientTypes.AttributeValue.s(name),
            "profilePictureURL": DynamoDBClientTypes.AttributeValue.s(profilePictureURL)
        ]
        let input = PutItemInput(item: itemValues, tableName: usersTable)
        do {
            _ = try await dynamoDBClient.putItem(input: input)
        } catch {
            print("ERROR in putDynamoDBItem: \(error)")
        }
    }
    
    static func getDynamoDBItem(uuid: String) async -> [String : DynamoDBClientTypes.AttributeValue]? {
        let keyToGet = ["uuid" : DynamoDBClientTypes.AttributeValue.s(uuid)]
        let input = GetItemInput(key: keyToGet, tableName: usersTable)
        do {
            return try await dynamoDBClient.getItem(input: input).item
        } catch {
            print("ERROR in getDynamoDBItem: \(error)")
        }
        return nil
    }
    
    static func updateDynamoDBItem(uuid: String,
                                   newName: String,
                                   newEmail: String,
                                   newProfilePictureURL: String) async {
        let itemKey = ["uuid" : DynamoDBClientTypes.AttributeValue.s(uuid)]
        let updatedValues = ["name": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newName)),
                             "email": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newEmail)),
                             "profilePictureURL": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newProfilePictureURL))]
        do {
            let _ = try await dynamoDBClient.updateItem(input: UpdateItemInput(attributeUpdates: updatedValues, key: itemKey, tableName: usersTable))
            
        } catch {
            print("ERROR in updateDynamoDBItem: \(error)")
        }
    }
    
    static func deleteDynamoDBItem(uuid: String) async {
        let keyToDelete = ["uuid" : DynamoDBClientTypes.AttributeValue.s(uuid)]
        
        do {
            let _ = try await dynamoDBClient.deleteItem(input: DeleteItemInput(key: keyToDelete,
                                                                               tableName: usersTable))
        } catch {
            print("ERROR in deleteDynamoDBItem: \(error)")
        }
        
    }
}
