//
//  ForecastedWeatherDayViewModel.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import Foundation

struct ForecastedWeatherDayViewModel {
    
    let dateFormatter: DateFormatter
    let weather: String
    let temp: String
    let feelsLike: String
    let tempMin: String
    let tempMax: String
    let cloudPercentage: String
    let date: String
    
    init(forecastedWeatherDay: ForcastedWeatherDay) {
        self.weather = forecastedWeatherDay.weather.first ?? "N/A"
        self.temp = String(format: "%.0f", forecastedWeatherDay.temp) + "°"
        self.feelsLike = String(format: "%.0f", forecastedWeatherDay.feelsLike) + "°"
        self.tempMin = String(format: "%.0f", forecastedWeatherDay.tempMin) + "°"
        self.tempMax = String(format: "%.0f", forecastedWeatherDay.tempMax) + "°"
        self.cloudPercentage = String(forecastedWeatherDay.cloudPercentage) + "%"
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = TimeZone.current
        let date = Date(timeIntervalSince1970: forecastedWeatherDay.date)
        self.date = dateFormatter.string(from: date)
    }
}
