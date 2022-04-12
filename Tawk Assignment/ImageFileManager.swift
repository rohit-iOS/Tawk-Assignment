//
//  ImageFileManager.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 12/04/2022.
//

import Foundation
import UIKit.UIImage

/// Manager class for Network layer
final class ImageFileManager: NSObject {
    
    private let fileManager = FileManager.default
    private let folderName = "/ImageStore"
    
    static let shared: ImageFileManager = {
        let instance = ImageFileManager()
        return instance
    }()
    
    private override init() {
        super.init()
        
        self.createDirectory()
    }

    private func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    private func createDirectory(){
        var paths = getDirectoryPath()
        paths = paths + folderName
        if !fileManager.fileExists(atPath: paths) {
            
            do {
                try fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        } else {
            print("Already directory created.")
        }
    }
    
    private func fileNameWithPathFor(urlString: String) -> String {
        let imagePath = getDirectoryPath()
        return imagePath + folderName + "/\(String(describing: urlString.components(separatedBy: "/").last!)).jpeg"
    }
    
    func saveImageDocumentDirectory(imageName: String, image: UIImage){
        let imagePath = fileNameWithPathFor(urlString: imageName)
        let imageData = image.jpegData(compressionQuality: 1.0)
        
        if !(imageData?.isEmpty ?? false) {
            if (fileManager.createFile(atPath: imagePath as String, contents: imageData, attributes: nil)) {
                print("File saved")
            } else {
                print("Not saved")
            }
        }
    }
    
    func getImage(imageName: String) -> UIImage?{
        let imagePath = fileNameWithPathFor(urlString: imageName)

        if fileManager.fileExists(atPath: imagePath){
            if let image = UIImage(contentsOfFile: imagePath) {
                return image
            } else {
                print("No Image")
            }
        } else {
            print("No Image")
        }
        return nil
    }
}
