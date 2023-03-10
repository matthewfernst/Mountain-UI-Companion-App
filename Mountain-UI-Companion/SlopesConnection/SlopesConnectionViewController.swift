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
import OSLog
import UniformTypeIdentifiers

extension UTType {
    static var slopes: UTType {
        UTType(filenameExtension: "slopes")!
    }
}

class SlopesConnectionViewController: UIViewController, UIDocumentPickerDelegate {
    @IBOutlet var explanationTitleLabel: UILabel!
    @IBOutlet var explanationTextView: UITextView!
    @IBOutlet var slopesFolderImageView: UIImageView!
    @IBOutlet var connectSlopesButton: UIButton!
    
    private var documentPicker: UIDocumentPickerViewController!
    private var bookmarks: [(uuid: String, url: URL)] = []
    
    private let profileViewModel = ProfileViewModel.shared
    
    private func getAppSandboxDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // loadAllBookmarks()
        
        if bookmarks.isEmpty {
            documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.folder], asCopy: false)
            documentPicker.delegate = self
            documentPicker.shouldShowFileExtensions = true
            documentPicker.allowsMultipleSelection = true
            
            connectSlopesButton.addTarget(self, action: #selector(selectSlopesFiles), for: .touchUpInside)
        }
        else {
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
    
    // MARK: Error Alert Functions
    func showErrorUploadingToS3Alert() {
        let ac = UIAlertController(title: "Error Uploading Slope Documents",
                                   message: """
                                    There was an error uploading your slope documents.
                                    Please try again.
                                    """,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        
        present(ac, animated: true)
    }
    
    func showFileAccessNotAllowed() {
        let ac = UIAlertController(title: "File Permission Error",
                                   message: """
                                    This app does not have permission to your files on your iPhone.
                                    Please allow this app to access your files by going to Settings.
                                    """,
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Go to Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                      return
                  }

                  if UIApplication.shared.canOpenURL(settingsUrl) {
                      UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                          Logger.slopesConnection.debug("Settings opened.")
                      })
                  }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func showFileExtensionNotSupported(file: URL) {
        let ac = UIAlertController(title: "File Extension Not Supported", message: "Only 'slope' file extensions are supported, but recieved \(file.pathExtension) extension. Please try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        
        present(ac, animated: true)
    }
    
    // MARK: Document Picker
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let url = urls[0]
        
        guard url.startAccessingSecurityScopedResource() else {
            // Handle the failure here.
            showFileAccessNotAllowed()
            return
        }
        
        defer { url.stopAccessingSecurityScopedResource() }
        
        let keys: [URLResourceKey] = [.nameKey, .isDirectoryKey]
        
        guard let fileList = FileManager.default.enumerator(at: url, includingPropertiesForKeys: keys) else {
            Logger.slopesConnection.debug("*** Unable to access the contents of \(url.path) ***\n")
            showFileAccessNotAllowed()
            return
        }
        
        for case let file as URL in fileList {
            if file.pathExtension == "slopes" {
                Logger.slopesConnection.debug("chosen file: \(file.lastPathComponent)")
                Task {
                    do {
                        try await S3Utils.uploadSlopesDataToS3(file: file)
                    } catch {
                        Logger.slopesConnection.debug("\(error)")
                        showErrorUploadingToS3Alert()
                    }
                }
                url.stopAccessingSecurityScopedResource()
                saveBookmark(for: url)
            } else {
                showFileExtensionNotSupported(file: file)
                Logger.slopesConnection.debug("Only slope file extensions are supported, but recieved \(file.pathExtension) extension.")
            }
        }
    }
    
    // MARK: Bookmarks
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
            Logger.slopesConnection.debug("Error creating the bookmark: \(error)")
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

    #warning ("TODO maybe not need?")
//    func removeBookmark(at offsets: IndexSet) {
//        let uuids = offsets.map( { bookmarks[$0].uuid } )
//
//        // Remove bookmarks from urls array
//        bookmarks.remove(atOffsets: offsets)
//
//        // Delete the bookmark file
//        uuids.forEach({ uuid in
//            let url = getAppSandboxDirectory().appendingPathComponent(uuid)
//            try? FileManager.default.removeItem(at: url)
//        })
//    }
    
    
}
