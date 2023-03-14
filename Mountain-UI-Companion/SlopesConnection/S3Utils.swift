//
//  S3Utils.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 3/13/23.
//
import AWSClientRuntime
import AWSS3
import ClientRuntime
import Foundation
import UIKit

enum S3BucketNames: String {
    case zippedSlopesBucketName = "mountain-ui-app-slopes-zipped"
    case profilePictureBucketName = "mountain-ui-users-profile-pictures"
}

struct S3Utils {
    private static let s3Client = try! S3Client(region: "us-east-1")
    
    private static let profileViewModel = ProfileViewModel.shared
    
    private static func getUUID() throws -> String {
        enum ValidationError: Error {
            case noUUID
        }
        guard let uuid = self.profileViewModel.profile?.uuid else { throw ValidationError.noUUID }
        return uuid
    }
    
    static func uploadSlopesDataToS3(file: URL) async throws {
        let fileKey = "\(try getUUID())/\(file.lastPathComponent)"
        let fileData = try Data(contentsOf: file)
        
        do {
            try await uploadData(fileKey: fileKey, fileData: fileData, bucketName: S3BucketNames.zippedSlopesBucketName.rawValue)
        } catch {
            print("\(error)")
        }
    }
    
    static func uploadProfilePictureToS3(picture: UIImage) async throws {
        let fileKey = "\(try getUUID())/profilePicture"
        let fileData = picture.jpegData(compressionQuality: 8.0)!
        
        do {
            try await uploadData(fileKey: fileKey, fileData: fileData, bucketName: S3BucketNames.profilePictureBucketName.rawValue)
        } catch {
            print("\(error)")
        }
    }
    
    private static func uploadData(fileKey: String, fileData: Data, bucketName: String) async throws {
        let _ = try await createFile(key: fileKey, data: fileData, bucketName: bucketName)
    }


    static func getObjectURL() async -> URL {
        do {
            let fileKey = "\(try getUUID())/profilePicture"
            let inputObject = GetObjectInput(bucket: S3BucketNames.profilePictureBucketName.rawValue, key: fileKey)
            let output = try await s3Client.getObject(input: inputObject)
            print("OUTPUT: \(output)")
            // ...
        } catch {
            dump(error)
        }
        
        return URL(string: "https://blog.imgur.com/wp-content/uploads/2016/05/dog33.jpg")!
    }

    
    static func createFile(key: String, data: Data, bucketName: String) async throws -> PutObjectOutputResponse {
        let dataStream = ByteStream.from(data: data)
        let input = PutObjectInput(
            body: dataStream,
            bucket: bucketName,
            key: key
        )
        return try await s3Client.putObject(input: input)
    }
}
