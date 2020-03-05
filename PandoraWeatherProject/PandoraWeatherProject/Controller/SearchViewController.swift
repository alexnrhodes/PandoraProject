//
//  SearchViewController.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var loactionSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loactionSearchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let cityName = loactionSearchBar.text else { return }
        NotificationCenter.default.post(name: .searchCityNameChosen, object: nil, userInfo: ["cityName": cityName])
        dismiss(animated: true, completion: nil)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        guard let cityName = loactionSearchBar.text else { return }
        NotificationCenter.default.post(name: .searchCityNameChosen, object: nil, userInfo: ["cityName": cityName])
        dismiss(animated: true, completion: nil)
    }
}
