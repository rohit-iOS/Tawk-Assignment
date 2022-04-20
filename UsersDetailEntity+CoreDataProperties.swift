//
//  UsersDetailEntity+CoreDataProperties.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 14/04/2022.
//
//

import Foundation
import CoreData


extension UsersDetailEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UsersDetailEntity> {
        return NSFetchRequest<UsersDetailEntity>(entityName: "UsersDetailEntity")
    }

    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var followers: Int16
    @NSManaged public var following: Int16
    @NSManaged public var id: Int16
    @NSManaged public var name: String?
    @NSManaged public var profilePictureUrl: String?
    @NSManaged public var public_gists: Int16
    @NSManaged public var public_repos: Int16
    @NSManaged public var username: String?

}

extension UsersDetailEntity : Identifiable {

}
