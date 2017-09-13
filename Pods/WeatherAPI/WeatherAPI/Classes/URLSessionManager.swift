
import UIKit

public enum ConnectionType {
    
    case get
    case post
    case put
    case delete
    case image
}

open class URLSessionManager: NSObject {
    
    
    class func request(_ connectionType: ConnectionType, url: String , data: Data, onSuccess: @escaping (AnyObject) -> Void, onError: @escaping(_ error: Error) -> Void) {
        
        switch connectionType {
        case ConnectionType.get:
            
            let urlString = url as NSString
            let encodedUrl = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let request = NSMutableURLRequest(url: URL(string: encodedUrl!)!)
            request.httpMethod = "GET"
            HTTPsendRequest(request, success: onSuccess, onError: onError)
            
        case ConnectionType.post:
            
            let urlString = url as NSString
            let encodedUrl = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let request = NSMutableURLRequest(url: URL(string: encodedUrl!)!)
            request.httpMethod = "POST"
            request.addValue("application/json",forHTTPHeaderField: "Content-Type")
            request.addValue("application/json",forHTTPHeaderField: "Accept")
            request.httpBody = data
            HTTPsendRequest(request, success: onSuccess, onError: onError)
            
        case ConnectionType.put:
            break
            
        case ConnectionType.delete:
            let request = NSMutableURLRequest(url: URL(string: url)! as URL)
            request.httpMethod = "DELETE"
            HTTPsendRequest(request, success: onSuccess, onError: onError)
        case ConnectionType.image:
            
            let urlString = url as NSString
            let encodedUrl = urlString.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)
            let request = NSMutableURLRequest(url: URL(string: encodedUrl!)!)
            request.httpMethod = "GET"
            HTTPImageDownloadRequest(request, success: onSuccess, onError: onError)
        }
    }
    
    
    class func HTTPsendRequest(_ request: NSMutableURLRequest,
                               success: @escaping (AnyObject) -> Void, onError: @escaping (_ error: Error) -> Void) {
        let task = URLSession.shared
            .dataTask(with: request as URLRequest) {
                (data, response, error) -> Void in
                if (error != nil) {
                    onError(error!)
                } else {
                    
                    let jsonString = NSString(data: data!,
                                              encoding: String.Encoding.utf8.rawValue)! as String
                    let jsonData = jsonString.parseJSONString
                    success(jsonData!)
                }
        }
        
        task.resume()
    }
    
    class func HTTPImageDownloadRequest(_ request: NSMutableURLRequest,
                               success: @escaping (UIImage) -> Void, onError: @escaping (_ error: Error) -> Void) {
        let task = URLSession.shared
            .dataTask(with: request as URLRequest) {
                (data, response, error) -> Void in
                if (error != nil) {
                    onError(error!)
                } else {
                    let image = UIImage(data:data!,scale:1.0)
                    if let tempImage = image {
                        success(tempImage)
                    }
                }
        }
        
        task.resume()
    }
}

extension String {
    
    var parseJSONString: AnyObject? {
        
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        
        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            let jsonResults = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0))
            return jsonResults as AnyObject?
        } else {
            return nil
        }
    }
}
