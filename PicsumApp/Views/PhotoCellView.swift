//
//  PhotoCellView.swift
//  PicsumApp
//
//  Created by Adriana Epure on 02/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import UIKit
import PromiseKit

class PhotoCellView: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    
     private var isLoading: Bool = false
       
       let queue = DispatchQueue(label: "CellQueue")
       
       var viewModel: PhotoCellViewModel?
       
       func configure(viewModel: PhotoCellViewModel?) {
           self.viewModel = viewModel
           let scale = traitCollection.displayScale;
           let maxPixelSize: CGFloat = frame.width * scale;
           viewModel?.maxPixelSize = maxPixelSize
           startLoading()
       }
    
    private func startLoading() {
            guard let viewModel = viewModel
             else
             {
                 displayLoadingUI(isLoading: true)
                 authorLabel.text = ""
                 return
             }
             
             authorLabel.text = viewModel.author()

            
             firstly {
                 viewModel.getPhotoData()
             }.done { [weak self] data in
                 self?.imageView.image = UIImage.init(data: data)
                 self?.displayLoadingUI(isLoading: false)
             }.catch { (error) in
                print("Error getting photo data: ", error)
             }
        }
    private func displayLoadingUI(isLoading: Bool)
       {
           isUserInteractionEnabled = !isLoading
           imageView.isHidden = isLoading
       }
       
       override func prepareForReuse() {
           super.prepareForReuse()
           imageView.image = nil
           authorLabel.text = ""
           displayLoadingUI(isLoading: true)
           viewModel?.setStopLoading()
       }
    
}

