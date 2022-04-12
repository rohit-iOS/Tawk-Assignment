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
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    imageCashe.setObject(image, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                    completion()
                    ImageFileManager.shared.saveImageDocumentDirectory(imageName: urlString, image: image)
                }
            }
        }
    }
}


extension UIViewController {
    
    func generateCopositeLayout() -> UICollectionViewLayout {
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(((self.view.bounds.width - 40)/2) * 1.50))
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(2/3))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 2)
        
        let section = NSCollectionLayoutSection(group: group)
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)
        return compositionalLayout
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
