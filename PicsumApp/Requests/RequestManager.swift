//
//  RequestManager.swift
//  PicsumApp
//
//  Created by Adriana Epure on 02/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class GenericError: Error { }

class RequestManager {
    private let queue = DispatchQueue(label: "RequestQueue")

    private static var sharedInstance = RequestManager()
    static func shared() -> RequestManager {
        return sharedInstance
    }

    private init() { }
    
    func fetchPhotos(page: Int, limit: Int) -> Promise<[PhotoModel]> {
        let q = DispatchQueue.global()
        let url = "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)"
        return firstly {
            Alamofire.request(url, method: .get).responseData()
            }
            .map(on: q) { data, response in
               return try JSONDecoder().decode([PhotoModel].self, from: data)
            }
    }
    
    func fetchPhoto(imageURL: URLConvertible) -> Promise<Data> {
        return firstly {
            Alamofire.request(imageURL).responseData()
        }.map(on: queue) { data, response in
            return data
        }
    }

}
