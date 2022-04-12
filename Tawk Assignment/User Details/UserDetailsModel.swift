//
//  UserDetailsModel.swift
//  Tawk Assignment
//
//  Created by Rohit Karyappa on 10/04/2022.
//

import Foundation

struct UserDetails: Codable {
    
    var userName: String
    var profilePictureUrl: String
    var name: String?
    var company: String?
    var blog: String?
    var following: Int
    var followers: Int
    var public_repos: Int
    var public_gists: Int
    
    enum CodingKeys: String, CodingKey {
        case userName = "login"
        case profilePictureUrl = "avatar_url"
        case name
        case company
        case blog
        case following
        case followers
        case public_repos
        case public_gists
    }
}


/*
 {
   "login": "defunkt",
   "id": 2,
   "node_id": "MDQ6VXNlcjI=",
   "avatar_url": "https://avatars.githubusercontent.com/u/2?v=4",
   "gravatar_id": "",
   "url": "https://api.github.com/users/defunkt",
   "html_url": "https://github.com/defunkt",
   "followers_url": "https://api.github.com/users/defunkt/followers",
   "following_url": "https://api.github.com/users/defunkt/following{/other_user}",
   "gists_url": "https://api.github.com/users/defunkt/gists{/gist_id}",
   "starred_url": "https://api.github.com/users/defunkt/starred{/owner}{/repo}",
   "subscriptions_url": "https://api.github.com/users/defunkt/subscriptions",
   "organizations_url": "https://api.github.com/users/defunkt/orgs",
   "repos_url": "https://api.github.com/users/defunkt/repos",
   "events_url": "https://api.github.com/users/defunkt/events{/privacy}",
   "received_events_url": "https://api.github.com/users/defunkt/received_events",
   "type": "User",
   "site_admin": false,
   "name": "Chris Wanstrath",
   "company": null,
   "blog": "http://chriswanstrath.com/",
   "location": null,
   "email": null,
   "hireable": null,
   "bio": "🍔",
   "twitter_username": null,
   "public_repos": 107,
   "public_gists": 273,
   "followers": 21404,
   "following": 210,
   "created_at": "2007-10-20T05:24:19Z",
   "updated_at": "2022-03-29T01:48:36Z"
 }
 */
