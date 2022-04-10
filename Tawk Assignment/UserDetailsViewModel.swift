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

    /// Initialization
    init(model: UserDetails? = nil) {
        if let inputModel = model {
            userDetails = inputModel
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
        
        NetworkManager.shared.request(requetparam: nil, fromURL: userDetailsUrl) { (result: Result<UserDetails, Error>) in
            
            
            switch result {
            case .success(let userDetailsResponse):
                
                self.userDetails = userDetailsResponse
                success()
                
            case .failure(let error):
                debugPrint("We got a failure trying to get the data. The error we got was: \(error.localizedDescription)")
                failure(error.localizedDescription)
            }
        }
    }
}

