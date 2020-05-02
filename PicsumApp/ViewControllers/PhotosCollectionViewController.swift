//
//  PhotosCollectionViewController.swift
//  PicsumApp
//
//  Created by Adriana Epure on 02/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import UIKit
import RealmSwift


class PhotosCollectionViewController: UIViewController{
    
    
    
    
    //MARK: - Outlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: - Properties
    let viewModel =  PhotosViewModel()
    let photoDetailSegue = "photoDetailSegue"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.prefetchDataSource = self
        self.activityIndicator.startAnimating()
        
        viewModel.delegate = self
        viewModel.getData(forIndexPaths: [IndexPath(item: 0, section: 0)])
        
    }
    
    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == photoDetailSegue {
            if let cell = sender as? UICollectionViewCell
            {
                if let index = collectionView.indexPath(for: cell)?.row
                {
                    let viewController = segue.destination as? PhotoDetailsViewController
                    viewController?.viewModel = viewModel.photoDetailsViewModel(atIndex: index)
                }
            }
        }
    }
}



//MARK: - PhotosViewModelDelegate Delegate

extension PhotosCollectionViewController: PhotosViewModelDelegate {
    func reloadDataForIndexes(indexPaths: [IndexPath]?) {
        guard let indexPaths = indexPaths else {
            collectionView.reloadData()
            return
        }
        
        let indexPathsForVisibleRows = collectionView.indexPathsForVisibleItems
        let indexPathsIntersection = Set(indexPathsForVisibleRows).intersection(indexPaths)
        collectionView.reloadItems(at: Array(indexPathsIntersection))
    }
    
}


//MARK: - Flow Layout Delegate

extension PhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let numberOfColumns: CGFloat = 1
        let width = collectionView.frame.size.width - 10
        let xInsets: CGFloat = 10
        let cellSpacing: CGFloat = 5
        let finalWidth = (width / numberOfColumns) - (xInsets + cellSpacing)
        return CGSize(width: finalWidth, height: finalWidth)
    }
}

//MARK: - DataSourcePrefetching

extension PhotosCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { (indexPath) -> Bool in return indexPath.row >= viewModel.numberOfAvailableItems() }) {
            viewModel.getData(forIndexPaths: indexPaths)
        }
    }
}

////MARK: - DataSource
extension PhotosCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCellView
        cell.configure(viewModel: viewModel.photoCellViewModel(forIndex: indexPath.row))
        return cell

    }

}
