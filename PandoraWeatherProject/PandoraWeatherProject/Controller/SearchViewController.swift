//
//  SearchViewController.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var loactionSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true
         let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
         let blurEffectView = UIVisualEffectView(effect: blurEffect)
         self.view = blurEffectView
       
    }
}
