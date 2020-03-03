//
//  ForecastedWeatherDayViewModel.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import Foundation

struct ForecastedWeatherDayViewModel {
    let weather: String
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let cloudPercentage: Int
    let date: Double
    
    init(forecastedWeatherDay: ForcastedWeatherDay) {
        self.weather = forecastedWeatherDay.weather.first ?? "N/A"
        self.temp = forecastedWeatherDay.temp
        self.feelsLike = forecastedWeatherDay.feelsLike
        self.tempMin = forecastedWeatherDay.tempMin
        self.tempMax = forecastedWeatherDay.tempMax
        self.cloudPercentage = forecastedWeatherDay.cloudPercentage
        self.date = forecastedWeatherDay.date
    }
}
