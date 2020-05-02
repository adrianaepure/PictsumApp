//
//  PhotoDetailViewController.swift
//  PicsumApp
//
//  Created by Adriana Epure on 03/05/2020.
//  Copyright © 2020 Adriana Epure. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController {
    var viewModel: PhotoDetailsViewModel?
    
    @IBOutlet weak var detailPhotoView: UIImageView!
    @IBOutlet weak var authorNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       if let viewModel = viewModel {
            authorNameLabel.text = viewModel.getAuthor()
            detailPhotoView.image = UIImage(data: viewModel.getPhotoData())
        }
    }
}

