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
    
    // MARK: IBOutlets
    
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
    @IBOutlet var forecastedWeatherDayViews: [UIView]!
    @IBOutlet weak var dayOneDayLabel: UILabel!
    @IBOutlet weak var dayTwoDayLabel: UILabel!
    @IBOutlet weak var dayThreeDayLabel: UILabel!
    @IBOutlet weak var dayFourDayLabel: UILabel!
    @IBOutlet weak var dayFiveDayLabel: UILabel!
    @IBOutlet weak var dayOneTempLabel: UILabel!
    @IBOutlet weak var dayTwoTempLabel: UILabel!
    @IBOutlet weak var dayThreeTempLabel: UILabel!
    @IBOutlet weak var dayFourTempLabel: UILabel!
    @IBOutlet weak var dayFiveTempLabel: UILabel!
    
    
    // MARK: Properties
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var network = Network()
    
    var forecastedWeatherDay: ForecastedWeatherDayViewModel?
    var currentCityName: String?
    var searchedCity: String? {
        didSet {
           getCLLocationFromSearch()
        }
    }
    var searchedLocation: CLLocation! {
        didSet {
           performFetchesWithSearchedLocation()
        }
    }
    var currentLocation: CLLocation! {
        didSet {
            performFetchedByCurrentLocation()
        }
    }
    var currentWeather: CurrentWeatherViewModel? {
        didSet {
            updateViews()
        }
    }
    var fiveDayForecast: [ForecastedWeatherDayViewModel]! {
        didSet {
            updateViews()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        addTapGestures()
        updateViews()
        coreLocationSetup()
        
    }
    
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ForecastedWeatherDayViewController {
            destination.forecastedWeatherDay = self.forecastedWeatherDay
            destination.cityName = self.currentCityName
        }
    }
}

// MARK: Methods


extension CurrentWeatherViewController {
    
    // MARK: Networking
    
    func performFetchedByCurrentLocation() {
        // fetch the current weather for current location
        network.fetchWeatherByLocation(location: currentLocation) { (currentWeather, error) in
            
            if let error = error {
                NSLog("Error retrieving weather by current location: \(error)")
            }
            
            if let currentWeather = currentWeather {
                print(currentWeather)
                self.currentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            }
        }
        
        // fetch five day for current location
        network.fetchFiveDayByLocation(location: currentLocation) { (forecastedWeatherDays, error) in
            
            if let error = error {
                NSLog("Error retrieving five day forecast by current location: \(error)")
            }
            
            if let forecastedWeatherDays = forecastedWeatherDays {
                let day = forecastedWeatherDays.map {ForecastedWeatherDayViewModel(forecastedWeatherDay: $0)}
                self.fiveDayForecast = day
                
            }
        }
    }
    
    func performFetchesWithSearchedLocation() {
        
        network.fetchWeatherByLocation(location: searchedLocation) { (currentWeather, error) in
            
            if let error = error {
                NSLog("Error retrieving weather by current location: \(error)")
            }
            
            if let currentWeather = currentWeather {
                print(currentWeather)
                self.currentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            }
        }
        
        // fetch five day for current location
        network.fetchFiveDayByLocation(location: searchedLocation) { (forecastedWeatherDays, error) in
            
            if let error = error {
                NSLog("Error retrieving five day forecast by current location: \(error)")
            }
            
            if let forecastedWeatherDays = forecastedWeatherDays {
                let day = forecastedWeatherDays.map {ForecastedWeatherDayViewModel(forecastedWeatherDay: $0)}
                self.fiveDayForecast = day
                
            }
        }
    }

    
    
    func getCLLocationFromSearch() {
        // Obtain CL Location from the searched city
        guard let searchedCity = searchedCity  else { return }
        geocoder.geocodeAddressString(searchedCity) { (placeMarks, error) in
            if let error = error {
                NSLog("Error getting CLLocation from searchTerm: \(searchedCity) with error:\(error)")
                return
            }
            
            guard let placemark = placeMarks?.first,
                let location = placemark.location else { return }
            self.searchedLocation = location
        }
    }
    
    // MARK: UI
    
    func updateViews() {
        
        let temps = fiveDayForecast.map { $0.map { $0.temp }}
        let days = fiveDayForecast.map { $0.map { $0.date }}
        
        // Update five day UI views
        DispatchQueue.main.async {
            self.forecastedWeatherDayViews.map{$0.map { $0.layer.cornerRadius = 30 }}
        }
        
        
        if let currentWeather = currentWeather  {
            DispatchQueue.main.async {
                // update UI elements on current weather
                self.weatherSegmentedControl.setTitle("\(currentWeather.cityName)", forSegmentAt: 0)
                self.currentTempLabel.text = "\(currentWeather.temp)°"
                self.highLabel.text = "\(currentWeather.tempMax)°"
                self.lowLabel.text = "\(currentWeather.tempMin)°"
                self.windSpeedLabel.text = "\(currentWeather.windSpeed) MPH"
                self.cloudPercentageLabel.text = "\(currentWeather.cloudPercentage) %"
                self.sunriseLabel.text = "\(currentWeather.sunrise) AM"
                self.sunsetLabel.text = "\(currentWeather.sunset) PM"
            }
        }
        
        if let fiveDayForecast = fiveDayForecast, let days = days, let temps = temps {
            
            DispatchQueue.main.async {
                print(fiveDayForecast)
                self.dayOneDayLabel.text = "\(days[0])"
                self.dayTwoDayLabel.text = "\(days[1])"
                self.dayThreeDayLabel.text = "\(days[2])"
                self.dayFourDayLabel.text = "\(days[3])"
                self.dayFiveDayLabel.text = "\(days[4])"
                
                self.dayOneTempLabel.text = "\(temps[0])"
                self.dayTwoTempLabel.text = "\(temps[1])"
                self.dayThreeTempLabel.text = "\(temps[2])"
                self.dayFourTempLabel.text = "\(temps[3])"
                self.dayFiveTempLabel.text = "\(temps[4])"
                
            }
        }
        
        if let searchedCity = searchedCity {
            DispatchQueue.main.async {
                self.weatherSegmentedControl.setTitle(searchedCity, forSegmentAt: 0)

            }
        }
    }
    
    // MARK: Tap Gesture Setup + Objc Methods
    
    func addTapGestures() {
        // Create gestures
        let tapOne = UITapGestureRecognizer(target: self, action: #selector(self.tapOne))
        let tapTwo = UITapGestureRecognizer(target: self, action: #selector(self.tapTwo))
        let tapThree = UITapGestureRecognizer(target: self, action: #selector(self.tapThree))
        let tapFour = UITapGestureRecognizer(target: self, action: #selector(self.tapFour))
        let tapFive = UITapGestureRecognizer(target: self, action: #selector(self.tapFive))
        
        let views = self.forecastedWeatherDayViews.map { $0 }.map { $0 }
        
        // Add gestures to views
        views![0].addGestureRecognizer(tapOne)
        views![1].addGestureRecognizer(tapTwo)
        views![2].addGestureRecognizer(tapThree)
        views![3].addGestureRecognizer(tapFour)
        views![4].addGestureRecognizer(tapFive)
        
    }
    
    @objc func tapOne() {
        self.forecastedWeatherDay = fiveDayForecast[0]
        checkForCurrentWeather()
        
    }
    
    @objc func tapTwo() {
        checkForCurrentWeather()
        self.forecastedWeatherDay = fiveDayForecast[1]
    }
    
    @objc func tapThree() {
        self.forecastedWeatherDay = fiveDayForecast[2]
        checkForCurrentWeather()
    }
    
    @objc func tapFour() {
        self.forecastedWeatherDay = fiveDayForecast[3]
        checkForCurrentWeather()
    }
    
    @objc func tapFive() {
        self.forecastedWeatherDay = fiveDayForecast[4]
        checkForCurrentWeather()
        
    }
    
    func checkForCurrentWeather() {
        guard let currentWeather = currentWeather else { return }
        self.currentCityName = currentWeather.cityName
        performSegue(withIdentifier: "ForecastedWeatherDetailSegue", sender: self)
    }
    
    // MARK: Observers
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .searchCityNameChosen, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo,
            let cityName = userInfo["name"] else {return}
            self.searchedCity = "\(cityName)"
            
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
    
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        currentLocation = locations.last
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        checkLocationAuthorization()
//    }
}

