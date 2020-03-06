//
//  ForecastedWeatherDayViewController.swift
//  PandoraWeatherProject
//
//  Created by Alex Rhodes on 3/1/20.
//  Copyright © 2020 Alexandra Rhodes. All rights reserved.
//

import UIKit

class ForecastedWeatherDayViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var cloudPercentageLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    var forecastedWeatherDay: ForecastedWeatherDayViewModel?
    var cityName: String?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    // MARK: Methods

    func updateViews() {
        // check for objects
        guard let forecastedWeatherDay = forecastedWeatherDay,
            let cityName = cityName else {return}
        // update UI
        dayLabel.text = forecastedWeatherDay.date
        cityNameLabel.text = cityName
        currentTempLabel.text = forecastedWeatherDay.temp
        weatherTypeLabel.text = forecastedWeatherDay.weather
        feelsLikeLabel.text = forecastedWeatherDay.temp
        highLabel.text = forecastedWeatherDay.tempMax
        lowLabel.text = forecastedWeatherDay.tempMin
        cloudPercentageLabel.text = forecastedWeatherDay.cloudPercentage
    }
    
}
