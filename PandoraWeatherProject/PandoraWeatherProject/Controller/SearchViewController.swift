//
//  SearchViewController.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var loactionSearchBar: UISearchBar!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loactionSearchBar.delegate = self
    }
    
    // MARK: Methods
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cityName = loactionSearchBar.text else { return }
        NotificationCenter.default.post(name: .searchCityNameChosen, object: nil, userInfo: ["name": cityName])
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let cityName = loactionSearchBar.text else { return }
        NotificationCenter.default.post(name: .searchCityNameChosen, object: nil, userInfo: ["name": cityName])
        dismiss(animated: true, completion: nil)
    }
}
