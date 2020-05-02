//
//  PhotoRequest.swift
//  PicsumApp
//
//  Created by Adriana Epure on 02/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import UIKit
import ObjectMapper
 
struct PhotoRequest : Mappable {
    
    var id : Int?
    var author : String?
    var image : String?
    var downsampledImage : String?
    
    init(id : Int , author : String , image : String, downsampledImage: String ) {
        self.id = id
        self.author = author
        self.image = image
        self.downsampledImage = downsampledImage
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.author <- map["author"]
        self.image <- map["image"]
        self.downsampledImage <- map["downsampledImage"]
    }
    
}
