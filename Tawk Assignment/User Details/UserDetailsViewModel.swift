//
//  UserDetailsViewModel.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//

import Foundation

/// ViewModel class for Users Listing
final class UserDetailsViewModel {
    
    var userDetails: UserDetails?
    private var userNote: String?

    /// Initialization
    init(model: UserDetails? = nil) {
        if let inputModel = model {
            userDetails = inputModel
        }
    }
    
    func getUserNote() -> String {
        if let note = userNote {
            return note
        }
        return ""
    }
    
    func fetchUserNote(success: @escaping (String) -> Void) {
        CoreDataManager.shared.fetchUserNotes(userName: userDetails!.userName) { [weak self] note in
            self?.userNote = note
            success(note)
        } failure: { errorMessage in
            debugPrint("We got a failure trying to get the note for user. The error we got was: \(errorMessage)")        }

    }
    
    func saveNotes(notes:String,
                   success: @escaping () -> Void,
                   failure: @escaping (String) -> Void) {
        CoreDataManager.shared.updateUserNotes(note: notes, userName: userDetails!.userName) {
            success()
        } failure: { errorMessage in
            failure(errorMessage)
        }

    }
}

// MARK: - Service call & Parsing
extension UserDetailsViewModel {
    
    func getUserDetailsFor(userName: String,
                           success: @escaping () -> Void,
                           failure: @escaping (String) -> Void) {
        
        guard let userDetailsUrl = URL(string: String(format: Constants.API.userDetailsURLString, userName)) else {
            return
        }
        
        NetworkManager.shared.request(requetparam: nil, fromURL: userDetailsUrl) { [weak self] (result: Result<UserDetails, Error>) in
            
            switch result {
            case .success(let userDetailsResponse):
                
                self?.userDetails = userDetailsResponse
                success()
                
            case .failure(let error):
                debugPrint("We got a failure trying to get the data. The error we got was: \(error.localizedDescription)")
                failure(error.localizedDescription)
            }
        }
    }
}

