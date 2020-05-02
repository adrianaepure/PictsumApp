//
//  PhotoModel.swift
//  PicsumApp
//
//  Created by Adriana Epure on 02/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//


import Foundation
import RealmSwift


struct PhotoModel: Codable {
    let id: String
    let author: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case author
        case imageURL = "download_url"
    }
    
    static func empty() -> PhotoModel?
    {
        return nil
    }
}

/**
 let path = "https://picsum.photos/v2/list?page=1&limit=10"
 id: "1003",
 author: "E+N Photographies",
 width: 1181,
 height: 1772,
 url: "https://unsplash.com/photos/GYumuBnTqKc",
 download_url: "https://picsum.photos/id/1003/1181/1772"
 },
 */
