//
//  CurrentWeatherViewModel.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import Foundation


struct CurrentWeatherViewModel {
    
    var numberFormatter = NumberFormatter()
    
    let cityName: String
    let weather: String
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let windSpeed: Double
    let cloudPercentage: Int
    let sunrise: Double
    let sunset: Double
    
    init(currentWeather: CurrentWeather) {
        self.cityName = currentWeather.cityName 
        self.weather = currentWeather.weather.first ?? "Not available"
        self.temp = currentWeather.temp // number formatter
        self.tempMin = currentWeather.tempMin // number formatter
        self.tempMax = currentWeather.tempMax // number formatter
        self.windSpeed = currentWeather.windSpeed // number formatter
        self.cloudPercentage = currentWeather.cloudPercentage
        self.sunrise = currentWeather.sunrise // date formatter
        self.sunset = currentWeather.sunset // date formatter
    }
    
}
