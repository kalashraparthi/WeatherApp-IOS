import CoreLocation
import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var weatherData = [Weather]()
    var locationManager = CLLocationManager()
    var lat : Double = 0
    var lon : Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        locationManager.delegate=self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        //using Waterloo as default location when no search is present
         updateWeatherForLocation(location: "Waterloo, ON")
        tableView.tableFooterView = UIView()
        
    }
    
    //update location with search bar input
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        if let locationInput = searchBar.text, !locationInput.isEmpty{
            updateWeatherForLocation(location: locationInput)
        }
        
    }
    
    //default location
    /*func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let l=locations[0]
        Weather.forecast(withLocation: l.coordinate, completion: { (results:[Weather]?) in
            if let data = results{
                self.weatherData = data
                DispatchQueue.main.sync {
                    self.tableView.reloadData()
                }
            }
        })
        
    }*/
    
    
    //Update location
    func updateWeatherForLocation(location: String)
    {
        CLGeocoder().geocodeAddressString(location) { (placemarks:[CLPlacemark]?, error:Error?) in
            if error == nil {
                
                if let location = placemarks?.first?.location {
                    
                    Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
                        if let data = results{
                            self.weatherData = data
                            
                            DispatchQueue.main.sync {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
            }
        }
        
    }
    
    // MARK: - Table view data source
    
    //number of sections is for 1 week daily weather
    override func numberOfSections(in tableView: UITableView) -> Int {
        return weatherData.count
    }
    
    //1 row in each section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //using section header for displaying day and date
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        //using calender to display date and days of the week
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        
        let dateFormatter = DateFormatter()
        
        //Setting custom date format to be displayed as a section header 
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        return dateFormatter.string(from: date!)
    }

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        
        
        let weatherObj = weatherData[indexPath.section]
        
        //Using the icon text to display weather summary
        let summary = weatherObj.icon
        
        //removing - from the summary if found
        let summaryParsed = summary.replacingOccurrences(of: "-", with: " ")
        
        //summary to all uppercase letters
        cell.textLabel?.text = summaryParsed.uppercased()
        
        //Temperature to C
        cell.detailTextLabel?.text = "\(Int((weatherObj.temperature - 32)/1.8)) °C"
        cell.imageView?.image = UIImage(named: weatherObj.icon)
        
        return cell
    }
}
