//
//  NoteCollectionViewCell.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 12/04/2022.
//

import Foundation
import UIKit

final class NoteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Cell configuration method
    /// - Parameter viewModel: viewModel
    func configureUserCell(viewModel: UserEntity) {
        usernameLabel.text = viewModel.username
        profilePictureImageView.image = UIImage.init(systemName: "photo")
        if let imageUrl = viewModel.profilePictureUrl {
            profilePictureImageView.loadImageFrom(urlString: imageUrl) {}
        }
    }    
}
