

import UIKit

public class WeatherAPI: NSObject {

    
    public func getWeatherInfo(url: String, onSuccess: @escaping (_ weatherModel: WeatherAPICollection) -> Void, onError: @escaping (_ error: Error) -> Void) {
        
        URLSessionManager.request(.get, url: url, data: Data(), onSuccess: { (serviceResponse) in
            
            let response = serviceResponse as? NSDictionary
            if let responseData = response {
                let weatherAPICollection = self.parseWeatherData(dictionary: responseData)
                onSuccess(weatherAPICollection)
            }
        }, onError: { (error) in
            
            onError(error)
        })
    }
    
    func parseWeatherData(dictionary: NSDictionary) -> WeatherAPICollection {
        
        let weatherAPICollection = WeatherAPICollection()
        
        let listArray = dictionary.object(forKey: "list") as! NSArray
        
        for i in 0...listArray.count - 1 {
            
            let weatherAPIModel = WeatherAPIModel()
            
            let dict = listArray.object(at: i) as? NSDictionary
            let mainDict = dict?.object(forKey: "main") as? NSDictionary
            weatherAPIModel.minTemp = mainDict?.object(forKey: "temp_min") as? Double
            weatherAPIModel.maxTemp = mainDict?.object(forKey: "temp_max") as? Double
            let currentTemp = mainDict?.object(forKey: "temp") as? Double
            if let kelvinTemp = currentTemp {
                weatherAPIModel.currentTemp = convertKelvinToFarenheit(kelvin: kelvinTemp)
            }
            
            
            let weatherArray = dict?.object(forKey: "weather") as? NSArray
            
            for i in 0...(weatherArray?.count)! - 1 {
                
                let weatherInfoModel = WeatherInfoModel()
                let dict = weatherArray?.object(at: i) as? NSDictionary
                weatherInfoModel.weatherId = dict?.object(forKey: "id") as? Int
                weatherInfoModel.main = dict?.object(forKey: "main") as? String
                weatherInfoModel.weatherDescription = dict?.object(forKey: "description") as? String
                weatherInfoModel.icon = dict?.object(forKey: "icon") as? String
                
                weatherAPICollection.weatherInfoModel.append(weatherInfoModel)
            }
            
            let weatherDateModel = WeatherDateModel()
            weatherDateModel.date = dict?.object(forKey: "dt_txt") as? String
            weatherAPICollection.weatherAPIModel.append(weatherAPIModel)
            weatherAPICollection.weatherDateModel.append(weatherDateModel)
        }
        return weatherAPICollection
    }
    
    func convertKelvinToFarenheit(kelvin: Double) -> Double {
        
        let farenheit = (9/5) * (kelvin - 273) + 32
        return farenheit
    }
}
