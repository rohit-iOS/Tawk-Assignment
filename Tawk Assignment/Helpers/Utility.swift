//
//  Utility.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 09/04/2022.
//

import Foundation
import UIKit

var imageCashe = NSCache<AnyObject, AnyObject>()
extension UIImageView {
    
    func loadImageFrom(urlString: String, completion: @escaping () -> Void) {
                
        ///Check image available in cashe and return it
        if let image = imageCashe.object(forKey: urlString as NSString) as? UIImage {
            self.image = image
            completion()
            return
        }
        
        ///Check image available on disk and return it
        if let image = ImageFileManager.shared.getImage(imageName: urlString) {
            self.image = image
            completion()
            return
        }
                
        guard let url = URL(string: urlString) else {
            return
        }

        ///Showing loading indicator
        let activityLoader = UIActivityIndicatorView(style: .large)
        activityLoader.startAnimating()
        activityLoader.hidesWhenStopped = true
        activityLoader.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityLoader)
        activityLoader.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        activityLoader.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true


        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    imageCashe.setObject(image, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        self?.image = image
                        activityLoader.stopAnimating()
                    }
                    completion()
                    ImageFileManager.shared.saveImageDocumentDirectory(imageName: urlString, image: image)
                }
            }
        }
    }
}

extension String {
    
    func isValidString() -> Bool {
        let trimmedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedString.isEmpty
    }
}

extension UIImage {
    func invertedImage() -> UIImage? {
        let placeHolderImage = UIImage.init(systemName: "photo")
        guard let cgImg = self.cgImage else { return placeHolderImage }
        let img = CoreImage.CIImage(cgImage: cgImg)
        guard let filter = CIFilter(name: "CIColorInvert") else { return placeHolderImage }
        filter.setDefaults()
        filter.setValue(img, forKey: "inputImage")
        let context = CIContext(options:nil)
        guard let outputImage = filter.outputImage else { return placeHolderImage }
        guard let cgimg = context.createCGImage(outputImage, from: (outputImage.extent)) else { return placeHolderImage }
        return UIImage(cgImage: cgimg)
    }
}
