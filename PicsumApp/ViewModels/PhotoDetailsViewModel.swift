//
//  PhotoDetailsViewModel.swift
//  PicsumApp
//
//  Created by Adriana Epure on 03/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import Foundation
import RealmSwift

// the class for the cache
class PhotoCacheDetailsRealm: Object
{
    @objc dynamic var id: Int = 0
    @objc dynamic var shouldClean: Bool = false
    @objc dynamic var storeTime = Date()
}

// Photo details class
class PhotoDetailsViewModel {
    var photoModel: PhotoModelRealm?
    
    init(photoModel: PhotoModelRealm?) {
        self.photoModel = photoModel
    }
    
    func getAuthor() -> String {
        return photoModel?.author ?? ""
    }
    
    func getPhotoData() -> Data {
        return photoModel?.image ?? Data()
    }
}
