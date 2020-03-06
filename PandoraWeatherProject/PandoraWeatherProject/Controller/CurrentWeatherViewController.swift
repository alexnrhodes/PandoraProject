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
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    
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
    
    // MARK: Lifelcycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        addTapGestures()
        updateViews()
        coreLocationSetup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        weatherSegmentedControl.selectedSegmentIndex = 0
    }
    
    // MARK: IBActions
    
    @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
        guard let currentWeather = displayedCurrentWeather  else { return }
        
        UserDefaults.standard.set(currentWeather.cityName, forKey: "favoriteCityWeather")
        updateViews()
    }
    
    @IBAction func weatherSegmentedControlChanged(_ sender: UISegmentedControl) {
        // adjusting segmented control to fetch based on proper location
        if sender.selectedSegmentIndex == 0 {
            performFetchesBySearchedLocation()
            updateViews()
        } else if sender.selectedSegmentIndex == 1 {
            getCLLocationFromFavoriteCity()
            performFetchesByFavoriteLocation()
            updateViews()
            // if there is no favorite city trigger alert
            if UserDefaults.standard.value(forKey: "favoriteCityWeather") == nil {
                let alert = UIAlertController(title: "Oops!", message: "Please select a favorite city by using the star button!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ForecastedWeatherDayViewController {
            destination.forecastedWeatherDay = self.forecastedWeatherDay
            destination.cityName = self.currentCityName
        }
    }
    
    // MARK: Networking Methods
    
    func performFetchedByCurrentLocation() {
        guard let currentLocation = currentLocation else { return }
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
        guard let searchedLocation = searchedLocation else { return }
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
        // current weather for favorite location
        network.fetchWeatherByLocation(location: favoriteCity) { (currentWeather, error) in
            if let error = error {
                NSLog("Error retrieving weather by current location: \(error)")
            }
            if let currentWeather = currentWeather {
                print(currentWeather)
                self.displayedCurrentWeather = CurrentWeatherViewModel(currentWeather: currentWeather)
            }
        }
        // fetch five day for favorite location
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
    
    func getCLLocationFromSearch() {
        // Obtain CL Location from the searched city
        guard let searchedCity = searchedCity  else { return }
        geocoder.geocodeAddressString(searchedCity) { (placeMarks, error) in
            if let error = error {
                let alert = UIAlertController(title: "Oops!", message: "We could not find that city!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Dismiss", style: .default)
                alert.addAction(action)
                self.present(alert, animated: true)
                NSLog("Error getting CLLocation from searchTerm: \(searchedCity) with error:\(error)")
                return
            }
            
            guard let placemark = placeMarks?.first,
                let location = placemark.location else { return }
            self.searchedLocation = location
        }
    }
    
    func getCLLocationFromFavoriteCity() {
        // Obtain CL Location from the searched city
        guard let favoriteCity = UserDefaults.standard.value(forKey: "favoriteCityWeather") else {return}
        geocoder.geocodeAddressString("\(favoriteCity)") { (placeMarks, error) in
            if let error = error {
                NSLog("Error getting CLLocation from searchTerm: \(favoriteCity) with error:\(error)")
            }
            guard let placemark = placeMarks?.first,
                let location = placemark.location else { return }
            self.favoriteLocation = location
        }
    }
    
    // MARK: UI Methods
    
    func updateViews() {
        
        // mapping the properties needed to populate five day views
        let temps = displayedFiveDayForecast.map { $0.map { $0.temp }}
        let days = displayedFiveDayForecast.map { $0.map { $0.date }}
        
        // Update five day UI views
        DispatchQueue.main.async {
            self.forecastedWeatherDayViews.map{$0.map { $0.layer.cornerRadius = 30 }}
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        }
        
        // if there is a weather view model, up date UI
        if let displayedCurrentWeather = displayedCurrentWeather  {
            DispatchQueue.main.async {
                // update UI elements on current weather
                self.weatherSegmentedControl.setTitle(displayedCurrentWeather.cityName, forSegmentAt: 0)
                self.currentTempLabel.text = displayedCurrentWeather.temp
                self.highLabel.text = displayedCurrentWeather.tempMax
                self.lowLabel.text = displayedCurrentWeather.tempMin
                self.windSpeedLabel.text = displayedCurrentWeather.windSpeed
                self.cloudPercentageLabel.text = displayedCurrentWeather.cloudPercentage
                self.sunriseLabel.text = displayedCurrentWeather.sunrise
                self.sunsetLabel.text = displayedCurrentWeather.sunset
            }
        }
        
        // if there is a five day forecast view model, up date UI
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
        // if there has been a searched performed changing the segmented control to reflect
        if let searchedCity = searchedCity {
            DispatchQueue.main.async {
                self.weatherSegmentedControl.setTitle(searchedCity, forSegmentAt: 0)
                
            }
        }
        
        // checking for a value for favorite warther and updating UI
        if let favoriteWeather = UserDefaults.standard.value(forKey: "favoriteCityWeather") {
            DispatchQueue.main.async {
                self.favoriteButton.image = UIImage(systemName: "star.fill")
                self.weatherSegmentedControl.setTitle("\(favoriteWeather)", forSegmentAt: 1)
            }
        }
        
        // will not allow user to select favorite segment if there is not favorite
        if UserDefaults.standard.value(forKey: "favoriteCityWeather") == nil {
            DispatchQueue.main.async {
                self.weatherSegmentedControl.selectedSegmentIndex = 0
            }
        }
        
        // move blur view if we do/do not have location
        if displayedCurrentWeather == nil {
            DispatchQueue.main.async {
                self.view.bringSubviewToFront(self.blurView)
            }
        } else {
            DispatchQueue.main.async {
                self.view.sendSubviewToBack(self.blurView)
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
        self.forecastedWeatherDay = displayedFiveDayForecast[1]
        checkForCurrentWeather()

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
    
    // MARK: Observer Methods
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .searchCityNameChosen, object: nil, queue: OperationQueue.main) { (notification) in
            guard let userInfo = notification.userInfo,
                let cityName = userInfo["name"] else {return}
            self.searchedCity = "\(cityName)"
            
        }
    }
}

extension CurrentWeatherViewController: CLLocationManagerDelegate {
    
    // MARK: CoreLocation Methods
    
    func coreLocationSetup() {
        setupLocationManager()
        checkLocationAuthorization()
    }
    
    func setupLocationManager() {
        // Set delegate and desired accuracy
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func checkLocationAuthorization() {
        // Check authorization for location tracking
        if CLLocationManager.authorizationStatus() != .authorizedAlways ||
            CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            print("requesting authorization")
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            updateViews()
        } else {
            locationManager.startUpdatingLocation()
            self.currentLocation = locationManager.location
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

