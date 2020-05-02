//
//  DataManager.swift
//  PicsumApp
//
//  Created by Adriana Epure on 03/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager {
    private let maxCacheSize = 50
    private let queue = DispatchQueue(label: "CacheQueue")
    private static var sharedInstance = DataManager()
    static func shared() -> DataManager {
        return sharedInstance
    }
    
    private init() { }
    
    //function to save photos to realm cache
    func save(photoModel: PhotoModelRealm) {
        queue.async {
            autoreleasepool {
                if photoModel.isInvalidated  { return }
                        
                let realm = try! Realm()
                //update the cache if is valid entity
                if let savedPhoto = self.getPhoto(id: photoModel.id), let cacheDetails = self.getCacheDetails(id: photoModel.id), !savedPhoto.isInvalidated && !cacheDetails.isInvalidated  {
                    try! realm.write {
                        savedPhoto.id = photoModel.id
                        savedPhoto.image = photoModel.image
                        savedPhoto.downsampledImage = photoModel.downsampledImage
                        savedPhoto.author = photoModel.author
                    
                        cacheDetails.shouldClean = false
                        cacheDetails.storeTime = Date.init()
                    }
                } else {
                    //photo does not exist in the cache or invalid, add to the cache
                    let cacheDetails = PhotoCacheDetailsRealm()
                    cacheDetails.id = photoModel.id
                    cacheDetails.shouldClean = false
                    cacheDetails.storeTime = Date.init()
                    
                    try! realm.write {
                        realm.add(photoModel)
                        realm.add(cacheDetails)
                    }
                }
                self.cleanupCache()
            }
        }
    }
    
    func getPhoto(id: Int) -> PhotoModelRealm? {
        let realm = try! Realm()
        
        if let photoModel = realm.objects(PhotoModelRealm.self).filter("id == \(id)").first {
            queue.async {
                autoreleasepool { [unowned self] in
                    let realm = try! Realm()
                    if let cachedDetails = self.getCacheDetails(id: id) {
                        try! realm.write {
                            cachedDetails.storeTime = Date.init()
                        }
                    }
                }
            }
            return photoModel
        }
        
        return nil
    }
    
    func getCacheDetails(id: Int) -> PhotoCacheDetailsRealm?
    {
        let realm = try! Realm()
        return realm.objects(PhotoCacheDetailsRealm.self).filter("id == \(id)").first
    }
    
    // cleanup cache if size is more than maxsize
    func cleanupCache() {
        let realm = try! Realm()
        let cacheDetails = realm.objects(PhotoCacheDetailsRealm.self).sorted(by: { $0.storeTime > $1.storeTime })
        
        if cacheDetails.count > maxCacheSize
        {
            let ids = cacheDetails.map { $0.id }
            let splitByItem = ids[maxCacheSize - 1]
            
            if let idsToDelete = ids.split(separator: splitByItem).last {
                let objectsToDelete = Array(realm.objects(PhotoModelRealm.self)).filter({idsToDelete.contains($0.id)})
                let cacheDetailsToDelete = Array(realm.objects(PhotoCacheDetailsRealm.self)).filter({idsToDelete.contains($0.id)})
                
                try! realm.write {
                    for object in objectsToDelete
                    {
                        realm.delete(object)
                    }
                    for cacheDetails in cacheDetailsToDelete
                    {
                        realm.delete(cacheDetails)
                    }
                }
            }
            
        }
    }
}
