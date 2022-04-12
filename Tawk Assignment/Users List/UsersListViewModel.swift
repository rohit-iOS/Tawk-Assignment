//
//  UsersListViewModel.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import Foundation

enum CellViewModelItemType {
   case Normal
   case Note
}

protocol CellViewModelItem {
   var type: CellViewModelItemType { get }
}


/// ViewModel class for Users Listing
final class UsersListViewModel {
    
    var userListDataSource:[UserEntity]?
    private var entityList: [UserEntity]?

    /// Initialization
    init(model: [UserEntity]? = nil) {
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
    func getUsersListData(_ success: @escaping () -> Void,
                          failure: @escaping (String) -> Void) {
        
        
        let pageNumber = ((userListDataSource?.count ?? 0) / Constants.Others.usersCountPerPage)
        let lastUserId = Int(userListDataSource?.last?.id ?? 0)

        guard let usersListurl = URL(string: Constants.API.usersListURLString + "\(lastUserId)") else {
            return
        }
        
        func callAPI() {
            fetchUsersList(usersListurl: usersListurl) {
                success()
            } failure: { errorMessage in
                failure(errorMessage)
            }
        }
        
        if let entityData = entityList {
            if entityData.count > (pageNumber * Constants.Others.usersCountPerPage) {
                let startIndex = (pageNumber * Constants.Others.usersCountPerPage)
                let endIndex = startIndex + Constants.Others.usersCountPerPage
                self.userListDataSource! += Array(entityData[startIndex..<endIndex])
                success()
            } else {
                callAPI()
            }
        } else if (pageNumber > 0)
        {
            callAPI()
        } else {
            do {
                entityList = try CoreDataManager.shared.fetchAllEntitiesFor(pageNumber: pageNumber)
                if let enityData = entityList {
                    self.userListDataSource = Array(enityData[0...(Constants.Others.usersCountPerPage - 1)])
                    success()
                }
                
            } catch UserListError.missingData {
                callAPI()
            } catch {
                debugPrint("We got a failure trying to get the data. The error we got was: \(error.localizedDescription)")
                failure(error.localizedDescription)
                
            }
        }
    }
    
    func fetchUsersList(usersListurl: URL,
                        success: @escaping () -> Void,
                        failure: @escaping (String) -> Void) {
        NetworkManager.shared.request(requetparam: nil, fromURL: usersListurl) { [weak self] (result: Result<[UserEntity], Error>) in
            
            switch result {
            case .success(let usersListDataResponse):
                
                Task {
                    try await CoreDataManager.shared.insertUserData(usersListDataResponse)
                }
                
                if  self?.userListDataSource != nil {
                    self?.userListDataSource! += usersListDataResponse
                }
                else {
                    self?.userListDataSource = usersListDataResponse
                }
                success()
                
            case .failure(let error):
                debugPrint("We got a failure trying to get the data. The error we got was: \(error.localizedDescription)")
                failure(error.localizedDescription)
            }
        }
    }
}
