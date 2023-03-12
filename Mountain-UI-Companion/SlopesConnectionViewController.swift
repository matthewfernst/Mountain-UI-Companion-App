//
//  SlopesHookupViewController.swift
//  Mountain-UI-Companion
//
//  Created by Matthew Ernst on 1/23/23.
//

import AWSClientRuntime
import AWSS3
import ClientRuntime
import UIKit
import UniformTypeIdentifiers

extension UTType {
    static var slopes: UTType {
        UTType(filenameExtension: "slopes")!
    }
}

class SlopesConnectionViewController: UIViewController, UIDocumentPickerDelegate {
    let bucketName = "mountain-ui-app-slopes-data"
    let s3Client = try! S3Client(region: "us-west-2")
    
    @IBOutlet var explanationTitleLabel: UILabel!
    @IBOutlet var explanationTextView: UITextView!
    @IBOutlet var slopesFolderImageView: UIImageView!
    @IBOutlet var connectSlopesButton: UIButton!
    
    var documentPicker: UIDocumentPickerViewController!
    var bookmarks: [(uuid: String, url: URL)] = []
    
    private func getAppSandboxDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllBookmarks()
        
        if bookmarks.isEmpty {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
            documentPicker.delegate = self
            documentPicker.shouldShowFileExtensions = true
            documentPicker.allowsMultipleSelection = true
            
            connectSlopesButton.addTarget(self, action: #selector(selectSlopesFiles), for: .touchUpInside)
            
        } else {
            explanationTitleLabel.text = "You're All Set!"
            explanationTitleLabel.font = UIFont.boldSystemFont(ofSize: 28)
            explanationTextView.text = "You've already connected your Slopes data to this app. If we lose access, we will notify you. For now, keep on shredding."
            explanationTextView.font = UIFont.systemFont(ofSize: 16)
            connectSlopesButton.isHidden = true
            showAllSet()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !bookmarks.isEmpty {
            showAllSet()
        }
    }
    
    @objc func selectSlopesFiles(_ sender: UIBarButtonItem) {
        present(documentPicker, animated: true)
    }
    
    func showAllSet() {
        slopesFolderImageView.tintColor = .systemBlue
        slopesFolderImageView.image = UIImage(systemName: "hand.thumbsup.fill")
        slopesFolderImageView.alpha = 0
        self.slopesFolderImageView.transform = .identity
        UIButton.animate(withDuration: 1, delay: 0, animations: {
            self.slopesFolderImageView.alpha = 1
            self.slopesFolderImageView.transform = CGAffineTransform(rotationAngle: -.pi / 4)
        }, completion: {_ in
            UIButton.animate(withDuration: 2, delay: 0,  usingSpringWithDamping: 0.4, initialSpringVelocity: 0.5, animations: {
                self.slopesFolderImageView.transform = .identity
            })
        })
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls[0]
        
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
        
        guard let fileList = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
            Swift.debugPrint("*** Unable to access the contents of \(url.path) ***\n")
            return
        }
        
        for case let file as URL in fileList {
            print(file.pathExtension)
            if file.pathExtension == "slopes" {
                Swift.debugPrint("chosen file: \(file.lastPathComponent)")
                Task {
                    do {
                        try await uploadSlopesDataToS3(file: file)
                    } catch {
                        print(error)
                    }
                }
                url.stopAccessingSecurityScopedResource()
                saveBookmark(for: url)
            } else {
                let ac = UIAlertController(title: "File Extension Not Supported", message: "Only 'slope' file extensions are supported, but recieved \(file.pathExtension) extension. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                present(ac, animated: true)
                Swift.debugPrint("Only slope file extensions are supported, but recieved \(file.pathExtension) extension.")
            }
        }
    }
    
    func saveBookmark(for url: URL) {
        do {
            // Start accessing a security-scoped resource.
            guard url.startAccessingSecurityScopedResource() else {
                // Handle the failure here.
                return
            }
            
            if bookmarks.contains (where: { bookmark in
                bookmark.url == url
            }) { return }
            
            // Make sure you release the security-scoped resource when you finish.
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Generate a UUID
            let uuid = UUID().uuidString
            
            // Convert URL to bookmark
            let bookmarkData = try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
            // Save the bookmark into a file (the name of the file is the UUID)
            try bookmarkData.write(to: getAppSandboxDirectory().appendingPathComponent(uuid))
            
            // Add the URL and UUID to the urls
            bookmarks.append((uuid, url))
            self.viewDidLoad()
        }
        catch {
            // Handle the error here.
            print("Error creating the bookmark: \(error.localizedDescription)")
        }
    }
    
    func loadAllBookmarks() {
        // Get all the bookmark files
        let files = try? FileManager.default.contentsOfDirectory(at: getAppSandboxDirectory(), includingPropertiesForKeys: nil)
        // Map over the bookmark files
        self.bookmarks = files?.compactMap { file in
            do {
                let bookmarkData = try Data(contentsOf: file)
                var isStale = false
                // Get the URL from each bookmark
                let url = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &isStale)
                
                guard !isStale else {
                    // Handle stale data here.
                    return nil
                }
                
                // Return URL
                return (file.lastPathComponent, url)
            }
            catch let error {
                // Handle the error here.
                print(error)
                return nil
            }
        } ?? []
    }
    
    func uploadSlopesDataToS3(file: URL) async throws -> PutObjectOutputResponse {
        let userEmail = UserDefaults.standard.string(forKey: "email")
        let fileKey = "\(String(describing: userEmail))/\(file.lastPathComponent)"
        let fileData = try Data(contentsOf: file)
        return try await createFile(key: fileKey, data: fileData)
    }
    
    func createFile(key: String, data: Data) async throws -> PutObjectOutputResponse {
        let dataStream = ByteStream.from(data: data)
        let input = PutObjectInput(
            body: dataStream,
            bucket: bucketName,
            key: key
        )
        return try await s3Client.putObject(input: input)
    }
    //        TODO: Maybe not needed??
    //        func removeBookmark(at offsets: IndexSet) {
    //            let uuids = offsets.map( { bookmarks[$0].uuid } )
    //
    //            // Remove bookmarks from urls array
    //            bookmarks.remove(atOffsets: offsets)
    //
    //            // Delete the bookmark file
    //            uuids.forEach({ uuid in
    //                let url = getAppSandboxDirectory().appendingPathComponent(uuid)
    //                try? FileManager.default.removeItem(at: url)
    //            })
    //        }
    
    
}
