//
//  UserEntity+CoreDataProperties.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var id: Int16
    @NSManaged public var note: String?
    @NSManaged public var profilePictureUrl: String?
    @NSManaged public var profileUrl: String?
    @NSManaged public var username: String?

}

extension UserEntity : Identifiable {

}
