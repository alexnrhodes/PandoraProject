//
//  CurrentWeatherViewModel.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import Foundation


class CurrentWeatherViewModel {
    
    let dateFormatter: DateFormatter
    let cityName: String
    let weather: String
    let temp: String
    let tempMin: String
    let tempMax: String
    let windSpeed: String
    let cloudPercentage: String
    let sunrise: String
    let sunset: String
    
    init(currentWeather: CurrentWeather) {
        self.cityName = currentWeather.cityName 
        self.weather = currentWeather.weather.first ?? "Not available"
        self.temp = String(format: "%.0f", currentWeather.temp) + "°"
        self.tempMin = String(format: "%.0f", currentWeather.tempMin) + "°"
        self.tempMax = String(format: "%.0f", currentWeather.tempMax) + "°"
        self.windSpeed = String(format: "%.0f", currentWeather.windSpeed) + "MPH"
        self.cloudPercentage = String(currentWeather.cloudPercentage) + "%"
        
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.timeZone = TimeZone.current
        let sunrise = Date(timeIntervalSince1970: currentWeather.sunrise)
        self.sunrise = dateFormatter.string(from: sunrise)
        let sunset = Date(timeIntervalSince1970: currentWeather.sunset)
        self.sunset = dateFormatter.string(from: sunset)
    }
    
}
