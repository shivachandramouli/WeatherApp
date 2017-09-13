
import UIKit
import WeatherAPI

//List of constants related to the web service API
struct ServerAPI {
    
    static let openWeatherURL = "https://api.openweathermap.org/data/2.5/"
    static let APPID = "940fb63cb447efca70b5e3ba1ca1bcdd"
    static let weatherBaseUrl = "http://openweathermap.org/img/w/"
}

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var textField: UITextField?
    @IBOutlet var searchBtn: UIButton?
    var searchTerm: String?
    @IBOutlet var searchLabel: UILabel?
    @IBOutlet var tableView: UITableView?
    var weatherAPICollection: WeatherAPICollection?
    let cachedCity = "CachedCity"
    
    let weatherAPI = WeatherAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Weather"
        textField?.delegate = self
        self.tableView?.estimatedRowHeight = 90.0
        
        //Check if the searched city was stored locally, if so retrieve 
        //the city and execute a search
        let cityName =  UserDefaults.standard.object(forKey: cachedCity) as? String
        
        if cityName != nil && (cityName?.characters.count)! > 0 {
            textField?.text = cityName
            executeSearch()
        }
    }
    
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Search Action
    @IBAction func searchAction() {
        
        executeSearch()
    }
    
    //Execute the search for the city the user has typed
    func executeSearch() {
        
        //Dismiss the text field
        textField?.resignFirstResponder()
        searchTerm = textField?.text
        var requestUrl = ""
        if let searchTermText = searchTerm {
            
            //If the search term was typed, save the search term before executing the search
            UserDefaults.standard.set(searchTermText, forKey: cachedCity)
            UserDefaults.standard.synchronize()
            searchLabel?.text = "You searched for \(searchTermText)"
            
            //Frame the search request URL
            requestUrl = ServerAPI.openWeatherURL + "forecast?q=\(searchTermText)&APPID=" + ServerAPI.APPID + "&cnt=5&unit=metrics"
        }
        
        textField?.text = ""
        
        //Check network availability, if not available, return
        
        checkNetworkAvailability()
        
        //Call web service to request for weather information
        weatherAPI.getWeatherInfo(url: requestUrl, onSuccess: { (weatherAPICollection) in
            
            if weatherAPICollection.weatherAPIModel.count > 0 {
                
                DispatchQueue.main.sync {
                    
                    self.clearData()
                    self.weatherAPICollection = weatherAPICollection
                    self.tableView?.dataSource = self
                    self.tableView?.delegate = self
                    self.tableView?.reloadData()
                    self.tableView?.invalidateIntrinsicContentSize()
                }
            }
        }, onError: { (error) in
            
            
        })
    }
    
    func clearData() {
        
        self.weatherAPICollection?.weatherDateModel.removeAll()
        self.weatherAPICollection?.weatherInfoModel.removeAll()
        self.weatherAPICollection?.weatherAPIModel.removeAll()
    }
    
    //MARK: UITableViewDataSource and Delegates
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (self.weatherAPICollection?.weatherAPIModel.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier") as! WeatherCell
        cell.contentView.backgroundColor = UIColor(red: 30/255.0, green: 159.0/255.0, blue: 235.0/255.0, alpha: 1.0)
        
        let weatherInfoModel = self.weatherAPICollection?.weatherInfoModel[0]
        let weatherDateModel = self.weatherAPICollection?.weatherDateModel[indexPath.row]
        let weatherAPIModel = self.weatherAPICollection?.weatherAPIModel[indexPath.row]
        if let date = weatherDateModel?.date {
            if let temparature = weatherAPIModel?.currentTemp {
                
                let tempTemp = Int(temparature)
                cell.weatherData.text = "The weather at \(date) is \(tempTemp) \u{00B0}F"
            }
        }
        
        if let tempWeatherId = weatherInfoModel?.weatherId {
            
            if let path = Bundle.main.path(forResource: "Weather", ofType: "plist") {
                let dictRoot = NSDictionary(contentsOfFile: path)
                if let dict = dictRoot {
                    if let value = dict[String(tempWeatherId)] {
                        cell.weatherInfo.text = value as? String
                    }
                }
            }
        }
        
        downloadImage(cell: cell, weatherInfoModel: weatherInfoModel!)
        
        return cell
    }
    
    //MARK: Download Image
    func downloadImage(cell: WeatherCell, weatherInfoModel: WeatherInfoModel) {
        
        let weatherImageApi = WeatherImageAPI()
        
        if let tempIcon = weatherInfoModel.icon {
            let imageUrl = "\(ServerAPI.weatherBaseUrl)\(tempIcon).png"
            weatherImageApi.getWeatherImage(url: imageUrl, onSuccess: { (weatherImage) in
                
                DispatchQueue.main.sync {
                    cell.weatherImage.image = weatherImage.weatherImage
                }
                
            }, onError: { (error) in
                
                
            })
        }
    }
    
    //MARK: Network Availability
    func checkNetworkAvailability() {
        
        if !Reachability.isConnectedToNetwork() {
            
            let alertView = UIAlertController(title: "", message: "Please check your internet connection", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                
            })
            alertView.addAction(action)
            self.present(alertView, animated: true, completion: nil)
            return
        }
    }
}

