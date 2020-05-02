//
//  PhotoCellViewModel.swift
//  PicsumApp
//
//  Created by Adriana Epure on 03/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit


protocol PhotoCellViewModelDelegate {
    func didUpdateLoadingState(photoCellViewModel: PhotoCellViewModel, loading: Bool)
}

class PhotoCellViewModel
{
    private let queue = DispatchQueue(label: "CellQueue")
    var delegate: PhotoCellViewModelDelegate?
    var maxPixelSize: CGFloat = 0
    var photoModel: PhotoModel
    var stopLoading: Bool = false
    
    init(model: PhotoModel, delegate: PhotoCellViewModelDelegate? = nil) {
        photoModel = model
        if let delegate = delegate {
            self.delegate = delegate
        }
    }
    
    func author() -> String {
        return photoModel.author
    }
    
    func id() -> Int {
        return Int(photoModel.id) ?? 0
    }
    
    func getPhotoData() -> Promise<Data> {
        stopLoading = false
        self.delegate?.didUpdateLoadingState(photoCellViewModel: self, loading: true)
        return firstly {
            Promise<Data> { [unowned self] promiseResolver in
                loadPhotoFromCache { [unowned self] data, error in
                    if self.stopLoading {
                        promiseResolver.reject(GenericError())
                        return
                    }
                    if let data = data {
                        promiseResolver.resolve(data, nil)
                        self.delegate?.didUpdateLoadingState(photoCellViewModel: self, loading: false)
                    }
                    else {
                        self.downloadPhoto(promiseResolver: promiseResolver)
                    }
                }
            }
        }
    }
    
    func setStopLoading() {
        stopLoading = true
    }
    //download the photo from the imageUrl
    private func downloadPhoto(promiseResolver: Resolver<Data>)
    {
        firstly {
            RequestManager.shared().fetchPhoto(imageURL: self.photoModel.imageURL)
        }.done { [weak self] data in
            guard let self = self else {
                promiseResolver.reject(GenericError())
                return
            }
            
            if self.stopLoading {
                promiseResolver.reject(GenericError())
            }
            
            self.queue.async { [weak self] in
                guard let self = self else {
                    promiseResolver.reject(GenericError())
                    return
                }
                
                if self.stopLoading {
                    promiseResolver.reject(GenericError())
                }
                
                if let photo = UIImage.downsampleImage(withData: data, shouldResize: true, maxPixelSize: self.maxPixelSize)?.addFilter(filter: .Fade) {
                    if self.stopLoading {
                        promiseResolver.reject(GenericError())
                    }
                    
                    let photoModelRealm = PhotoModelRealm()
                    photoModelRealm.id = self.id()
                    photoModelRealm.author = self.photoModel.author
                    photoModelRealm.image = data
                    
                    if let downsampledImageData = photo.pngData()
                    {
                        photoModelRealm.downsampledImage = downsampledImageData
                        promiseResolver.fulfill(downsampledImageData)
                    }
                    DataManager.shared().save(photoModel: photoModelRealm)
                    self.delegate?.didUpdateLoadingState(photoCellViewModel: self, loading: false)
                }
            }
        }.catch { (error) in
            promiseResolver.reject(GenericError())
        }
    }
    
    private func loadPhotoFromCache(completion: @escaping (Data?, Error?) -> ())
    {
        queue.async { [unowned self] in
            if let photoModel = DataManager.shared().getPhoto(id: self.id()) {
                completion(photoModel.downsampledImage, nil)
            } else {
                completion(nil, GenericError())
            }
        }
    }
}
