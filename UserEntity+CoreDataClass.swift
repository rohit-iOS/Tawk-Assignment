//
//  UserEntity+CoreDataClass.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject, Codable, CellViewModelItem {
    var type: CellViewModelItemType {
        guard let note = self.note else {
            return .Normal
        }
       return note.isEmpty ? .Normal : .Note
    }
   
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(username ?? "" , forKey: .username)
            try container.encode(id, forKey: .id)
            try container.encode(profilePictureUrl ?? "" , forKey: .profilePictureUrl)
            try container.encode(profileUrl ?? "" , forKey: .profileUrl)
            try container.encode(note ?? "" , forKey: .note)
            
        } catch {
            print("error")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case id
        case profilePictureUrl = "avatar_url"
        case profileUrl = "url"
        case note
    }
    
    required convenience public init(from decoder: Decoder) throws {
        // return the context from the decoder userinfo dictionary
        guard let contextUserInfoKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "UserEntity", in: managedObjectContext)
        else {
            fatalError("decode failure")
        }
        // Super init of the NSManagedObject
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            username = try? values.decode(String.self, forKey: .username)
            let userId = try? values.decode(Int.self, forKey: .id)
            id = Int16(userId ?? 0)
            profilePictureUrl = try? values.decode(String.self, forKey: .profilePictureUrl)
            profileUrl = try? values.decode(String.self, forKey: .profileUrl)
            note = try? values.decode(String.self, forKey: .note)
        }
    }
    
    // The keys must have the same name as the attributes of the User entity.
    var dictionaryValue: [String: Any] {
        [
            "username": username ?? "",
            "id": id,
            "profilePictureUrl": profilePictureUrl ?? "",
            "profileUrl": profileUrl ?? "",
            "note": note ?? ""
        ]
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "context")
}
