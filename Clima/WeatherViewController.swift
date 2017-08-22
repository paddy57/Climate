//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegates {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "d9ac121ea2e0f86f18d0d08dfee25c1a"
    

    //TODO: Declare instance variables here
    //creating object of lcation manager
    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        //locationmanager helps us to get gps coordinate
        //to use locationmanager we use delegate and we set delegate to self
        locationManager.delegate = self
        
        //accurecy of location under 100m
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //permission to use location 
        locationManager.requestWhenInUseAuthorization()
    
        //location manager starts for looking location 
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    
    func  getWeatherData(url: String, parameters: [String: String]){
    
    //alamofire hepls to get data see there parameters url,method and parameters
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
           response in
            if response.result.isSuccess {
            
                print("successfull connection got the data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                print(weatherJSON)
                
                self.updateWeathrData(json: weatherJSON)
            }
            else{
            
                print("Error \(response.result.error)")
                self.cityLabel.text = "connection Issues"
                
            }
        
        }
    
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeathrData(json : JSON) {
        
        
        if  let tempResult = json["main"]["temp"].double {
            
            weatherDataModel.temprature = Int(tempResult - 273.15)
            
            weatherDataModel.city = json["name"].stringValue
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.country = json["sys"]["country"].stringValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
            updateUIWithWeatherData()
           
            
        }
            
        else {
            
            cityLabel.text = "weather Unavailable"
            
            
        }
        
    }

    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temprature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        countryLabel.text = weatherDataModel.country
        
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    //it will tell delegates i.e we that location data is got by location manager
    //and location coordinates gets stored into a array which is CLLocation
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //last value of the array will be more accurate
       let location = locations[locations.count - 1]
        //to validate location
        if location.horizontalAccuracy > 0 {
         locationManager.stopUpdatingLocation()
            //gives data once only no repeatation of data
            locationManager.delegate = nil
            
            print("logitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
        
            
            getWeatherData(url : WEATHER_URL, parameters: params)
        }
    }
    
    
    
    
    //Write the didFailWithError method here:
    //this method will activate if we didn't get the location and weill tell to view i.e to us
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredCityName(city: String) {
      
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any? ){
    
        if segue.identifier == "changeCityName" {
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
    
    
}


