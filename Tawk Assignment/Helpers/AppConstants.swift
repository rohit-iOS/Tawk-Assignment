//
//  AppConstants.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import Foundation

enum Section {
    case main
}

struct Constants {
    
    struct API {
        static let usersListURLString = "https://api.github.com/users?since="
        static let userDetailsURLString = "https://api.github.com/users/%@"
        
    }
    
    struct Identifiers {
        static let main = "Main"
        static let userCollactionViewCell = "UserCollectionViewCell"
    }
    
    struct Others {
        static let usersCountPerPage = 30
    }
    
}