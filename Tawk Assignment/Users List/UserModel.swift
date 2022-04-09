//
//  UserModel.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 08/04/2022.
//

import Foundation

/// Model struct for User data
struct User: Codable, Hashable {
    var username: String
    var id: Int
    var profilePictureUrl: String
    var profileUrl: String
    var note: String?
    
    enum CodingKeys: String, CodingKey {
    case username = "login"
        case id
        case profilePictureUrl = "avatar_url"
        case profileUrl = "url"
        case note
    }
}


//Sample repsonse for User model
//{
//    "login": "mojombo",
//    "id": 1,
//    "node_id": "MDQ6VXNlcjE=",
//    "avatar_url": "https://avatars.githubusercontent.com/u/1?v=4",
//    "gravatar_id": "",
//    "url": "https://api.github.com/users/mojombo",
//    "html_url": "https://github.com/mojombo",
//    "followers_url": "https://api.github.com/users/mojombo/followers",
//    "following_url": "https://api.github.com/users/mojombo/following{/other_user}",
//    "gists_url": "https://api.github.com/users/mojombo/gists{/gist_id}",
//    "starred_url": "https://api.github.com/users/mojombo/starred{/owner}{/repo}",
//    "subscriptions_url": "https://api.github.com/users/mojombo/subscriptions",
//    "organizations_url": "https://api.github.com/users/mojombo/orgs",
//    "repos_url": "https://api.github.com/users/mojombo/repos",
//    "events_url": "https://api.github.com/users/mojombo/events{/privacy}",
//    "received_events_url": "https://api.github.com/users/mojombo/received_events",
//    "type": "User",
//    "site_admin": false
//  },
