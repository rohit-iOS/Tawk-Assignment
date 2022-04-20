//
//  UserDetailsViewModel.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//

import Foundation

/// ViewModel class for Users Listing
final class UserDetailsViewModel {
    
    var userDetails: UsersDetailEntity?
    private var userNote: String?

    /// Initialization
    init(model: UsersDetailEntity? = nil) {
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
    
    private func fetchUserNote(success: @escaping (String) -> Void) {
        
        guard let username = userDetails?.username else { return }
        CoreDataManager.shared.fetchUserNotes(userName: username) { [weak self] note in
            self?.userNote = note
            success(note)
        } failure: { errorMessage in
            debugPrint("We got a failure trying to get the note for user. The error we got was: \(errorMessage)")        }

    }
    
    func saveNotes(notes:String,
                   success: @escaping () -> Void,
                   failure: @escaping (String) -> Void) {
        
        guard let username = userDetails?.username else { return }
        CoreDataManager.shared.updateUserNotes(note: notes, userName: username) { [weak self] in
            self?.fetchUserNote { _ in }
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
        
        func callAPI() {
            fetchUserDetailsFromServerFor(userName: userName) {
                success()
            } failure: { errorMessage in
                failure(errorMessage)
            }
        }
        
        do {
            ///Reading users list data from core data
            userDetails = try CoreDataManager.shared.fetchAllEntitiesFor(pageNumber: pageNumber)
            if let enityData = entityList {
                self.userListDataSource = Array(enityData[0...(Constants.Others.usersCountPerPage - 1)])
                success()
            }
        }///Data is not present in core data for requested page then requesting to server
        catch UserListError.missingData {
            callAPI()
        }
        catch {
            debugPrint("We got a failure trying to get the data. The error we got was: \(error.localizedDescription)")
            failure(error.localizedDescription)
            
        }
    }
    
    /// Fetch user details of selected user
    /// - Parameters:
    ///   - userName: userName
    ///   - success: successCompletionBlock
    ///   - failure: failureCompletionBlock
    func fetchUserDetailsFromServerFor(userName: String,
                           success: @escaping () -> Void,
                           failure: @escaping (String) -> Void) {
        
        
        NetworkManager.shared.request(requetparam: nil, fromURL: userDetailsUrl) { [weak self] (result: Result<UsersDetailEntity, Error>) in
            
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

