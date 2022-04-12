//
//  UserDetailsViewController.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//

import UIKit

final class UserDetailsViewController: UIViewController {
    
    var userName: String = ""
    private var viewModel = UserDetailsViewModel()
    private var keyboardHeight = CGFloat(0)
    private var scrollHeight = CGFloat(0)
    private var tapGestureReconizer = UITapGestureRecognizer()
    
    @IBOutlet weak var profilePictureImageView: BadgeImageView!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var repositoryCountLabel: UILabel!
    @IBOutlet weak var gistsCountLabel: UILabel!
    @IBOutlet weak var userDetailsVerticalStackView: UIStackView!
    @IBOutlet weak var userDetailsVerticalStackViewBackgroudView: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserDetails()
        
        tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.tap(_:)))
        view.addGestureRecognizer(tapGestureReconizer)
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailsViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func fetchUserDetails() {
        viewModel.getUserDetailsFor(userName: userName) { [weak self] in
            self?.updateUI()
        } failure: { [weak self] errorString in
            let errorMessageAlert = UIAlertController(title: "Got error", message: errorString, preferredStyle: .alert)
            errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(errorMessageAlert, animated: true, completion: nil)
        }
    }
    
    func updateUI() {
        guard let userDetails = viewModel.userDetails else { return }
        self.title = userDetails.userName
        profilePictureImageView.loadImageFrom(urlString: userDetails.profilePictureUrl)
        followingCountLabel.text = "Following: \(userDetails.following)"
        followersCountLabel.text = "Followers: \(userDetails.followers)"
        repositoryCountLabel.text = "Reps: \(userDetails.following)"
        gistsCountLabel.text = "Gists: \(userDetails.following)"
        
        if let name = userDetails.name, !name.isValidString() {
            addUserInfoLabel(userInfo:"Name: \(name)")
        }
        
        if let company = userDetails.company, !company.isValidString() {
            addUserInfoLabel(userInfo: "Company: \(company)")
        }
        
        if let blog = userDetails.blog, !blog.isValidString() {
            addUserInfoLabel(userInfo: "Blog: \(blog)")
        }
        
        func addUserInfoLabel(userInfo: String) {
            let userInfoLabel = UILabel()
            userInfoLabel.font = followingCountLabel.font
            userInfoLabel.text = userInfo
            userInfoLabel.numberOfLines = 0
            userDetailsVerticalStackViewBackgroudView.isHidden = false
            userDetailsVerticalStackView.addArrangedSubview(userInfoLabel)
        }
        
        viewModel.fetchUserNote { [weak self] note in
            self?.notesTextView.text = note
        }
    }
    
    @IBAction func saveNotesButtonAction(_ sender: UIButton) {
        
        if notesTextView.text.isValidString() {
            viewModel.saveNotes(notes: notesTextView.text) {
                NotificationCenter.default.post(name: .selectedUserDataDidChange, object: nil)
            } failure: { [weak self] errorMessage in
                let errorMessageAlert = UIAlertController(title: "Got error", message: errorMessage, preferredStyle: .alert)
                errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self?.present(errorMessageAlert, animated: true, completion: nil)
            }
        }
    }
    
}

extension UserDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = textView.text.isValidString()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let bottom = (self.view.frame.height - (saveButton.frame.origin.y +  saveButton.frame.height))
        scrollHeight = keyboardHeight - bottom
        animateViewMoving(true, moveValue: scrollHeight)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(false, moveValue: scrollHeight)
    }
    
    func animateViewMoving (_ up:Bool, moveValue :CGFloat){
        if moveValue < 0 {
            view.removeGestureRecognizer(tapGestureReconizer)
            return
        }
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.animate(withDuration: movementDuration, delay: 0, options: UIView.AnimationOptions.allowUserInteraction) { [weak self] in
            self?.view.frame = (self?.view.frame.offsetBy(dx: 0,  dy: movement))!
        } completion: { _ in
        }
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    }
}
