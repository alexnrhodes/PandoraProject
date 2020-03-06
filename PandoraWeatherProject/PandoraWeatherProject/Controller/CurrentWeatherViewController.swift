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
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    
    
    // MARK: Properties
    
    let geocoder = CLGeocoder()
    let locationManager = CLLocationManager()
    var network = Network()
    
    
    var forecastedWeatherDay: ForecastedWeatherDayViewModel?
    var currentCityName: String?
    var searchedCity: String?
    
    var favoriteLocation: CLLocation? {
        didSet {
            performFetchesByFavoriteLocation()
        }
    }
    var searchedLocation: CLLocation! {
        didSet {
           performFetchesBySearchedLocation()
        }
    }
    var currentLocation: CLLocation! {
        didSet {
            performFetchedByCurrentLocation()
        }
    }
    var displayedCurrentWeather: CurrentWeatherViewModel? {
        didSet {
            updateViews()
        }
    }
    var displayedFiveDayForecast: [ForecastedWeatherDayViewModel]! {
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
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        guard let currentWeather = displayedCurrentWeather  else { return }
        UserDefaults.standard.set(currentWeather.cityName, forKey: "favoriteCityWeather")
        updateViews()
    }
    
    @IBAction func weatherSegmentedControlChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 1 {
            getCLLocationFromFavoriteCity()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ForecastedWeatherDayViewController {
            destination.forecastedWeatherDay = self.forecastedWeatherDay
            destination.cityName = self.currentCityName
        }
    }
}

// MARK: IBActions

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
                self.displayedCurrentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            }
        }
        
        // fetch five day for current location
        network.fetchFiveDayByLocation(location: currentLocation) { (forecastedWeatherDays, error) in
            
            if let error = error {
                NSLog("Error retrieving five day forecast by current location: \(error)")
            }
            
            if let forecastedWeatherDays = forecastedWeatherDays {
                let fiveDay = forecastedWeatherDays.map {ForecastedWeatherDayViewModel(forecastedWeatherDay: $0)}
                self.displayedFiveDayForecast = fiveDay
                
            }
        }
    }
    
    func performFetchesBySearchedLocation() {
        
        // fetch current weather by seearched location
        network.fetchWeatherByLocation(location: searchedLocation) { (currentWeather, error) in
            
            if let error = error {
                NSLog("Error retrieving weather by current location: \(error)")
            }
            
            if let currentWeather = currentWeather {
                print(currentWeather)
                self.displayedCurrentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            }
        }
        
        // fetch five day for searched Location
        network.fetchFiveDayByLocation(location: searchedLocation) { (forecastedWeatherDays, error) in
            
            if let error = error {
                NSLog("Error retrieving five day forecast by current location: \(error)")
            }
            
            if let forecastedWeatherDays = forecastedWeatherDays {
                let fiveDay = forecastedWeatherDays.map {ForecastedWeatherDayViewModel(forecastedWeatherDay: $0)}
                self.displayedFiveDayForecast = fiveDay
                
            }
        }
    }

    func performFetchesByFavoriteLocation() {
        guard let favoriteCity = favoriteLocation else { return }
        
        network.fetchWeatherByLocation(location: favoriteCity) { (currentWeather, error) in
            
            if let error = error {
                NSLog("Error retrieving weather by current location: \(error)")
            }
            
            if let currentWeather = currentWeather {
                print(currentWeather)
                self.displayedCurrentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            }
        }
        
        // fetch five day for current location
        network.fetchFiveDayByLocation(location: favoriteCity) { (forecastedWeatherDays, error) in
            
            if let error = error {
                NSLog("Error retrieving five day forecast by current location: \(error)")
            }
            
            if let forecastedWeatherDays = forecastedWeatherDays {
                let day = forecastedWeatherDays.map {ForecastedWeatherDayViewModel(forecastedWeatherDay: $0)}
                self.displayedFiveDayForecast = day
                
            }
        }
    }
    
    func cityNameToLocation(_ locationString: String) -> CLLocation {
        var newLocation: CLLocation!
        
       geocoder.geocodeAddressString(locationString) { (placeMarks, error) in
            if let error = error {
                NSLog("Error getting CLLocation from searchTerm: \(locationString) with error:\(error)")
                return
            }
            
            guard let placemark = placeMarks?.first,
                let location = placemark.location else { return }
            newLocation = location
        }

        return newLocation
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
    
    func getCLLocationFromFavoriteCity() {
        guard let favoriteCity = UserDefaults.standard.value(forKey: "favoriteCityWeather") else {return}

           // Obtain CL Location from the searched city
           geocoder.geocodeAddressString("\(favoriteCity)") { (placeMarks, error) in
               if let error = error {
                   NSLog("Error getting CLLocation from searchTerm: \(favoriteCity) with error:\(error)")
                   return
               }
               
               guard let placemark = placeMarks?.first,
                   let location = placemark.location else { return }
               self.favoriteLocation = location
           }
       }
    
    // MARK: UI
    
    func updateViews() {
        
        let temps = displayedFiveDayForecast.map { $0.map { $0.temp }}
        let days = displayedFiveDayForecast.map { $0.map { $0.date }}
        
        // Update five day UI views
        DispatchQueue.main.async {
            self.forecastedWeatherDayViews.map{$0.map { $0.layer.cornerRadius = 30 }}
        }
        
        
        if let currentWeather = displayedCurrentWeather  {
            DispatchQueue.main.async {
                // update UI elements on current weather
                self.weatherSegmentedControl.setTitle(currentWeather.cityName, forSegmentAt: 0)
                self.currentTempLabel.text = currentWeather.temp
                self.highLabel.text = currentWeather.tempMax
                self.lowLabel.text = currentWeather.tempMin
                self.windSpeedLabel.text = currentWeather.windSpeed
                self.cloudPercentageLabel.text = currentWeather.cloudPercentage
                self.sunriseLabel.text = currentWeather.sunrise
                self.sunsetLabel.text = currentWeather.sunset
            }
        }
        
        if let fiveDayForecast = displayedFiveDayForecast, let days = days, let temps = temps {
            
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
        
        if let favoriteWeather = UserDefaults.standard.value(forKey: "favoriteCityWeather") {
            DispatchQueue.main.async {
                self.favoriteButton.image = .strokedCheckmark
                self.weatherSegmentedControl.setTitle("\(favoriteWeather)", forSegmentAt: 1)
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
        self.forecastedWeatherDay = displayedFiveDayForecast[0]
        checkForCurrentWeather()
        
    }
    
    @objc func tapTwo() {
        checkForCurrentWeather()
        self.forecastedWeatherDay = displayedFiveDayForecast[1]
    }
    
    @objc func tapThree() {
        self.forecastedWeatherDay = displayedFiveDayForecast[2]
        checkForCurrentWeather()
    }
    
    @objc func tapFour() {
        self.forecastedWeatherDay = displayedFiveDayForecast[3]
        checkForCurrentWeather()
    }
    
    @objc func tapFive() {
        self.forecastedWeatherDay = displayedFiveDayForecast[4]
        checkForCurrentWeather()
        
    }
    
    func checkForCurrentWeather() {
        guard let currentWeather = displayedCurrentWeather else { return }
        self.currentCityName = currentWeather.cityName
        performSegue(withIdentifier: "ForecastedWeatherDetailSegue", sender: self)
    }
    
    // MARK: Observers
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .searchCityNameChosen, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo,
            let cityName = userInfo["name"] else {return}
            self.searchedCity = "\(cityName)"
            self.searchedLocation = self.cityNameToLocation("\(cityName)")
            
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

