//
//  UserCollectionViewCell.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import UIKit

/// Cell class to diplay users list
final class UserCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var noteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    /// Cell configuration method
    /// - Parameter viewModel: viewModel
    func configureUserCell(viewModel: UserEntity) {
        usernameLabel.text = viewModel.username
        if let note = viewModel.note {
            noteImageView.isHidden = !note.isValidString()
        } else {
            noteImageView.isHidden = true
        }
        profilePictureImageView.image = UIImage.init(systemName: "photo")
        profilePictureImageView.loadImageFrom(urlString: viewModel.profilePictureUrl ?? "")
    }
    
}
