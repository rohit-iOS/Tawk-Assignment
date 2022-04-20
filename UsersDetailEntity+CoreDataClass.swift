//
//  UsersDetailEntity+CoreDataClass.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 14/04/2022.
//
//

import Foundation
import CoreData


public class UsersDetailEntity: NSManagedObject, Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(username ?? "" , forKey: .username)
            try container.encode(profilePictureUrl ?? "", forKey: .profilePictureUrl)
            try container.encode(name ?? "" , forKey: .name)
            try container.encode(blog ?? "" , forKey: .blog)
            try container.encode(following, forKey: .following)
            try container.encode(followers, forKey: .followers)
            try container.encode(public_repos, forKey: .public_repos)
            try container.encode(public_gists, forKey: .public_gists)

        } catch {
            print("error")
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case username = "login"
        case profilePictureUrl = "avatar_url"
        case name
        case company
        case blog
        case following
        case followers
        case public_repos
        case public_gists
    }
    
    required convenience public init(from decoder: Decoder) throws {
        // return the context from the decoder userinfo dictionary
        guard let contextUserInfoKey = CodingUserInfoKey.context,
              let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "UsersDetailEntity", in: managedObjectContext)
        else {
            fatalError("decode failure")
        }
        // Super init of the NSManagedObject
        self.init(entity: entity, insertInto: managedObjectContext)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        do {
            username = try? values.decode(String.self, forKey: .username)
            profilePictureUrl = try? values.decode(String.self, forKey: .profilePictureUrl)
            name = try? values.decode(String.self, forKey: .name)
            company = try? values.decode(String.self, forKey: .company)
            blog = try? values.decode(String.self, forKey: .blog)
            let followingCount = try? values.decode(Int16.self, forKey: .following)
            following = followingCount ?? 0
            let followersCount = try? values.decode(Int16.self, forKey: .followers)
            followers = followersCount ?? 0
            let public_reposCount = try? values.decode(Int16.self, forKey: .public_repos)
            public_repos = public_reposCount ?? 0
            let public_gistsCount = try? values.decode(Int16.self, forKey: .public_gists)
            public_gists = public_gistsCount ?? 0

        }
    }
    
    // The keys must have the same name as the attributes of the User entity.
    var dictionaryValue: [String: Any] {
        [
            "username": username ?? "",
            "profilePictureUrl": profilePictureUrl ?? "",
            "name": name ?? "",
            "company": company ?? "",
            "blog": blog ?? "",
            "following": following,
            "followers": followers,
            "public_repos": public_repos,
            "public_gists": public_gists
        ]
    }
}
