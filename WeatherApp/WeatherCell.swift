

import UIKit

class WeatherCell: UITableViewCell {

    @IBOutlet var weatherImage: UIImageView!
    @IBOutlet var weatherData: UILabel!
    @IBOutlet var weatherInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
