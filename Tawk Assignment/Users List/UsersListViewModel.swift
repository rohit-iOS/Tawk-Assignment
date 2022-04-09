//
//  UsersListViewModel.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import Foundation


/// ViewModel class for Users Listing
final class UsersListViewModel {
    var userListDataSource: [User]?
    
    /// Initialization
    init(model: [User]? = nil) {
        if let inputModel = model {
            userListDataSource = inputModel
        }
    }
}

// MARK: - Service call & Parsing
extension UsersListViewModel {
    
    /// fetch product list data
    /// - Parameters:
    ///   - success: successCompletionBlock
    ///   - failure: failureCompletionBlock
    func getUsersListData(
        success: @escaping () -> Void,
        failure: @escaping (String) -> Void) {
            
            guard let usersListurl = URL(string: Constants.API.usersListURLString) else {
                return
            }
            
            NetworkManager.shared.request(requetparam: nil, fromURL: usersListurl) { [weak self] (result: Result<[User], Error>) in
                
                switch result {
                case .success(let usersListDataResponse):
                    self?.userListDataSource = usersListDataResponse
                    success()
                    
                case .failure(let error):
                    debugPrint("We got a failure trying to get the data. The error we got was: \(error.localizedDescription)")
                    failure(error.localizedDescription)
                }
            }
        }
}
