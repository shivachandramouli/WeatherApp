

import UIKit

public class WeatherImageAPI: NSObject {

    public func getWeatherImage(url: String, onSuccess: @escaping (_ weatherImage: WeatherImage) -> Void, onError: @escaping (_ error: Error) -> Void) {
        
        URLSessionManager.request(.image, url: url, data: Data(), onSuccess: { (serviceResponse) in
            
            let weatherImage = WeatherImage()
            weatherImage.weatherImage = serviceResponse as? UIImage
            onSuccess(weatherImage)
            
        }, onError: { (error) in
            
            onError(error)
        })
    }
}
