//
//  CurrentWeatherViewController.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentWeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherSegmentedControl: UISegmentedControl!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var cloudPercentageLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var changeLocationButton: UIBarButtonItem!
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var forecastedWeatherTableView: UITableView!
    
    var network = Network()
    var locationManager = CLLocationManager()
    
    var currentLocation: CLLocation! {
        didSet {
             getWeatherByCurrentLocation()
        }
    }
    var currentWeather: CurrentWeatherViewModel? {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coreLocationSetup()
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

// MARK: TableView Data Source Methods

extension CurrentWeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

// MARK: Methods

// Networking
extension CurrentWeatherViewController {
    
    func getWeatherByCurrentLocation() {
        
        network.fetchWeatherByLocation(location: currentLocation) { (currentWeather, error) in
            if let currentWeather = currentWeather {
                print(currentWeather)
                self.currentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            } else {
                NSLog("Error retrieving weather by current location: \(String(describing: error))")
            }
        }
    }
    
    func updateViews() {
        guard let currentWeather = currentWeather else { return }
        
        DispatchQueue.main.async {
            self.currentTempLabel.text = "\(currentWeather.temp)°"
            self.highLabel.text = "\(currentWeather.tempMax)°"
            self.lowLabel.text = "\(currentWeather.tempMin)°"
            self.windSpeedLabel.text = "\(currentWeather.windSpeed) MPH"
            self.cloudPercentageLabel.text = "\(currentWeather.cloudPercentage) %"
            self.sunriseLabel.text = "\(currentWeather.sunrise) AM"
            self.sunsetLabel.text = "\(currentWeather.sunset) PM"

        }
    }
}

// MARK: CoreLocation

extension CurrentWeatherViewController: CLLocationManagerDelegate {
    
    func coreLocationSetup() {
        
        // Check authorization for location tracking
        checkLocationAuthorization()
        
        // Set delegate and desited accuracy
        setupLocationManager()
        
        // Get current location
        checkForCurrentLocation()
        
    }
    
    
    func checkLocationAuthorization() {
        // Check authorization for location tracking
        if CLLocationManager.authorizationStatus() != .authorizedAlways ||
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            print("requesting authorization")
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func checkForCurrentLocation() {
         // Get current location
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.currentLocation = locationManager.location
        }
    }
    
    func setupLocationManager() {
        // Set delegate and desired accuracy
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        // performFetchesByLocation(location: userLocation!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
