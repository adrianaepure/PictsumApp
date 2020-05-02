//
//  PhotosViewModel.swift
//  PicsumApp
//
//  Created by Adriana Epure on 03/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import Foundation
import RealmSwift
import PromiseKit

//the Realm class for PhotoViewModel
class PhotoModelRealm: Object
{
    @objc dynamic var id :Int = 0
    @objc dynamic var author :String = ""
    @objc dynamic var image: Data = Data()
    @objc dynamic var downsampledImage: Data = Data()
}

protocol PhotosViewModelDelegate
{
    func reloadDataForIndexes(indexPaths: [IndexPath]?)
}

// The PhotosViewModel class
class PhotosViewModel {
    private let itemsPerPage = 10
    private var photos: [PhotoModel?] = []
    private var fullyLoadedPages : [Int] = []
    private var currentPage = 1
    private var isListFinished: Bool = false
    
    var delegate: PhotosViewModelDelegate?
    
    func numberOfAvailableItems() -> Int {
        return photos.count
    }
    
    // utmost 100 images
    func numberOfRows() -> Int {
        return isListFinished ? numberOfAvailableItems() : 100
    }
    
    func photoCellViewModel(forIndex index: Int) -> PhotoCellViewModel? {
        guard photos.count > index, let model = photos[index] else {
            return nil
        }

        // return the cell model
        return PhotoCellViewModel(model: model)
    }
    
    // to get the photo model
    func photoDetailsViewModel(atIndex index: Int) -> PhotoDetailsViewModel? {
        let photoModel = photos[index]
        let id = Int(photoModel?.id ?? "0") ?? 0
        return PhotoDetailsViewModel(photoModel: DataManager.shared().getPhoto(id: id))
    }
    
    // get the unloaded pages function
    private func getUnloadedPages(forIndexPaths indexPaths: [IndexPath]) -> [Int] {
        var pages = [Int]()
        for indexPath in indexPaths {
            let page: Int = (indexPath.row / itemsPerPage) + 1
            if !pages.contains(page) && !fullyLoadedPages.contains(page) {
                pages.append(page)
            }
        }
        
        return pages
    }
    
    // get data function for initial page
    func getData(forIndexPaths indexPaths: [IndexPath]?) {
        guard let indexPaths = indexPaths
            else {
                return
        }
        
        let unloadedPages = getUnloadedPages(forIndexPaths: indexPaths)
        
        // get image list for each page
        for page in unloadedPages {
            updateDataSource(withPhotoModels: Array<PhotoModel?>(repeating: PhotoModel.empty(), count: itemsPerPage), forPage: page, shouldReplace: false)
            firstly {
                // get the image list for the page
                RequestManager.shared().fetchPhotos(page: page, limit: itemsPerPage)
            }.done { photoModels in
                DispatchQueue.main.async { [unowned self] in
                    self.updateDataSource(withPhotoModels: photoModels, forPage: page, shouldReplace: true)
                    if !self.fullyLoadedPages.contains(page) {
                        self.fullyLoadedPages.append(page)
                    }
                    self.delegate?.reloadDataForIndexes(indexPaths: self.indexesToReload(forPage: page))
                }
            }.catch { error in
                print("error in getting image list", error)
            }
        }
    }
    
    private func updateDataSource(withPhotoModels photoModels: [PhotoModel?], forPage page: Int, shouldReplace: Bool) {
        let startLimit = (page - 1) * itemsPerPage
        let pageLimit = page * itemsPerPage
        
        if photos.count >= pageLimit {
            let range = startLimit..<pageLimit
            if (shouldReplace) {
                photos.replaceSubrange(range, with: photoModels)
            }
        }
        else if photos.count >= startLimit {
            let range = startLimit..<photos.count
            if (shouldReplace) {
                photos.replaceSubrange(range, with: photoModels)
            }
            let replacedItems = photos.count - startLimit
            photos.append(contentsOf: photoModels[replacedItems...])
        } else {
            let emptyItems = Array<PhotoModel?>(repeating: nil, count: startLimit - photos.count)
            photos.append(contentsOf: emptyItems)
            photos.append(contentsOf: photoModels)
        }
    }
    
    // reload indexes on page scroll
    private func indexesToReload(forPage page: Int) -> [IndexPath] {
        let startLimit = (page - 1) * itemsPerPage
        let pageLimit = page * itemsPerPage
        return (startLimit..<pageLimit).map { IndexPath(row: $0, section: 0) }
    }
}

