//
//  PhotoResponse.swift
//  PicsumApp
//
//  Created by Adriana Epure on 02/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import UIKit
import ObjectMapper
 
struct UserResponse: Mappable {
    
    var message : String?
    var error : Bool?
    var photo : PhotoModel?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.photo <- map["photo"]
        self.message <- map["message"]
        self.error <- map["error"]
    }
    
}
