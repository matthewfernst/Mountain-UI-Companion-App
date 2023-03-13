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
    
    static func putDynamoDBItem(name: String, email: String, profilePictureURL: String) async {
        let itemValues = [
            "name": DynamoDBClientTypes.AttributeValue.s(name),
            "email": DynamoDBClientTypes.AttributeValue.s(email),
            "profilePictureURL": DynamoDBClientTypes.AttributeValue.s(profilePictureURL)
        ]
        let input = PutItemInput(item: itemValues, tableName: usersTable)
        do {
            _ = try await dynamoDBClient.putItem(input: input)
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    static func getDynamoDBItem(email: String) async -> [String : DynamoDBClientTypes.AttributeValue]? {
        let keyToGet = ["email" : DynamoDBClientTypes.AttributeValue.s(email)]
        let input = GetItemInput(key: keyToGet, tableName: usersTable)
        do {
            return try await dynamoDBClient.getItem(input: input).item
        } catch {
            print("ERROR: \(error)")
        }
        return nil
    }
    
    static func updateDynamoDBItem(email: String,
                                   newName: String,
                                   newProfilePictureURL: String) async {
        let itemKey = ["email" : DynamoDBClientTypes.AttributeValue.s(email)]
        let updatedValues = ["name": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newName)),
                             "profilePictureURL": DynamoDBClientTypes.AttributeValueUpdate(action: .put, value: DynamoDBClientTypes.AttributeValue.s(newProfilePictureURL))]
        do {
            let _ = try await dynamoDBClient.updateItem(input: UpdateItemInput(attributeUpdates: updatedValues, key: itemKey, tableName: usersTable))
            
        } catch {
            print("ERROR: \(error)")
        }
    }
    
    static func deleteDynamoDBItem(email: String) async {
        let keyToDelete = ["email" : DynamoDBClientTypes.AttributeValue.s(email)]
        
        do {
            let _ = try await dynamoDBClient.deleteItem(input: DeleteItemInput(key: keyToDelete,
                                                                               tableName: usersTable))
        } catch {
            print("ERROR: \(error)")
        }
        
    }
}
