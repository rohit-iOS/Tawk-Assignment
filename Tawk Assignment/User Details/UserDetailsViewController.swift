//
//  UserDetailsViewController.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//

import UIKit

final class UserDetailsViewController: UIViewController {
    
    ///Properties
    var userName: String = ""
    private var viewModel = UserDetailsViewModel()
    private var keyboardHeight = CGFloat(0)
    private var scrollHeight = CGFloat(0)
    private var tapGestureReconizer = UITapGestureRecognizer()
    
    ///IBOutlets
    @IBOutlet weak var profilePictureImageView: BadgeImageView!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var repositoryCountLabel: UILabel!
    @IBOutlet weak var gistsCountLabel: UILabel!
    @IBOutlet weak var userDetailsVerticalStackView: UIStackView!
    @IBOutlet weak var userDetailsVerticalStackViewBackgroudView: UIView!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchUserDetails()

        tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(UserDetailsViewController.tap(_:)))
        view.addGestureRecognizer(tapGestureReconizer)
        NotificationCenter.default.addObserver(self, selector: #selector(UserDetailsViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc private func tap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    /// Display intial user details
    private func updateUI() {
        updateBackButtonAppearance()
        
        func setUpData(){
            
            guard let userDetails = viewModel.userDetails else { return }

            self.title = userDetails.username
            profilePictureImageView.loadImageFrom(urlString: userDetails.profilePictureUrl ?? "") {}
            followingCountLabel.text = "Following: \(userDetails.following)"
            followersCountLabel.text = "Followers: \(userDetails.followers)"
            repositoryCountLabel.text = "Reps: \(userDetails.following)"
            gistsCountLabel.text = "Gists: \(userDetails.following)"
            
            if let name = userDetails.name, name.isValidString() {
                addUserInfoLabel(userInfo:"Name: \(name)")
            }
            
            if let company = userDetails.company, company.isValidString() {
                addUserInfoLabel(userInfo: "Company: \(company)")
            }
            
            if let blog = userDetails.blog, blog.isValidString() {
                addUserInfoLabel(userInfo: "Blog: \(blog)")
            }
            
            ///Adding users information programatically to stackView
            func addUserInfoLabel(userInfo: String) {
                let userInfoLabel = UILabel()
                userInfoLabel.font = followingCountLabel.font
                userInfoLabel.text = userInfo
                userInfoLabel.numberOfLines = 0
                userDetailsVerticalStackViewBackgroudView.isHidden = false
                userDetailsVerticalStackView.addArrangedSubview(userInfoLabel)
            }
            notesTextView.text = viewModel.getUserNote()
        }
        UIView.animate(withDuration: 1.6, delay: 0, options: UIView.AnimationOptions.allowUserInteraction) {
            setUpData()
        } completion: { _ in }
    }
    
    /// Customized appearance for navigation back button
    private func updateBackButtonAppearance() {
        let customeBackImage = UIImage(systemName: "arrow.backward")
        self.navigationController?.navigationBar.backIndicatorImage = customeBackImage
        self.navigationController?.navigationBar.backItem?.title = ""
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = customeBackImage
    }
    
    /// Fetch user details data to display
    private func fetchUserDetails() {
        viewModel.getUserDetailsFor(userName: userName) { [weak self] in
            self?.updateUI()
            self?.activityIndicator.stopAnimating()
        } failure: { [weak self] errorString in
            let errorMessageAlert = UIAlertController(title: "Got error", message: errorString, preferredStyle: .alert)
            errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(errorMessageAlert, animated: true, completion: nil)
            self?.activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func saveNotesButtonAction(_ sender: UIButton) {
        viewModel.saveNotes(notes: notesTextView.text) { [weak self] in
            NotificationCenter.default.post(name: .selectedUserDataDidChange, object: nil)
            self?.saveButton.isEnabled = false
        } failure: { [weak self] errorMessage in
            let errorMessageAlert = UIAlertController(title: "Got error", message: errorMessage, preferredStyle: .alert)
            errorMessageAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(errorMessageAlert, animated: true, completion: nil)
        }
    }
}

extension UserDetailsViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = textView.text != viewModel.getUserNote()
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
