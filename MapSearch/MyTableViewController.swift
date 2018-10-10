//
//  MyTableViewController.swift
//  MapSearch
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/8/29.
//
//
/*
 Copyright (C) 2017 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 Primary view controller used to display search results.
 */

import UIKit
import CoreLocation
import SVProgressHUD
import MapKit
import Moya
import SwiftyJSON

//mark: -

private let kCellIdentifier = "cellIdentifier"

@objc(MyTableViewController)
class MyTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var places: [MKMapItem] = []
    
    private var boundingRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    private var localSearch: MKLocalSearch?
    @IBOutlet weak var localSwitch: UISwitch!
    @IBOutlet weak var viewAllButton: UIBarButtonItem!
    private var locationManager: CLLocationManager = CLLocationManager()
    private var userCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    private var searchController: UISearchController!
    //###
    @IBOutlet weak var searchBar: UISearchBar!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [Restaurant]()
    var isAutoSuggest: Bool?
    var searchText: String? = ""
    //MARK: -
    
    @IBAction func switchValueChange(_ sender: Any) {
        
        let latitude = "25.033671"
        let longitude = "121.564427"
        var parameter = [String:String]()
        
        if localSwitch.isOn {
            parameter["latitude"] = latitude
            parameter["longitude"] = longitude
            
        }
        
        parameter["filter"] = self.searchText ?? ""
        
        MoyaProvider<DRApi>().request(.getAutoComplete(accessToken: self.appDelegate.accessToken, parameter: parameter)) { (result) in
            let results = self.searchResults.filter{ $0.shopID == nil }
            self.searchResults.removeAll()
//            for result in results {
//                let rest = Restaurant(shopID: nil, shopName: result.shopName, address: result.address)
//                self.searchResults.append(rest)
//            }
            switch result {
            case .success(let response):
                do{
                    let json = try JSON(data: response.data)
                    let restaurantResult = try JSONDecoder.init().decode(CommonResult<[Restaurant]>.self, from: response.data)
                    if let restaurants = restaurantResult.restaurantData {
                        self.searchResults = results + restaurants
                        //                        self.searchResults = restaurants + self.searchResults
                    }
                } catch let e {
                    print(e)
                }
            case .failure(let error):
                print(error)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        MoyaProvider<DRApi>().request(.login(email: "pei@qqq.com", password: "1234567890")) { (result) in
            switch result {
            case .success(let response):
                do{
                    let json = try JSON(data: response.data)
                    self.appDelegate.accessToken = json["accessToken"].string!
                } catch let e {
                    print(e)
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        if #available(iOS 11.0, *) {
            
            searchController = UISearchController(searchResultsController: nil)
            
            // We place the search bar in the navigation bar.
            self.navigationItem.searchController = self.searchController;
            
            // We want the search bar visible all the time.
            self.navigationItem.hidesSearchBarWhenScrolling = false
            
            self.searchController.dimsBackgroundDuringPresentation = false
            self.searchController.searchBar.delegate = self
            
            searchCompleter.delegate = self
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sleep(2)
        if self.searchText == "" {
            self.searchCompleter.queryFragment = "附近的餐廳"
        }
    }
//    override var shouldAutorotate : Bool {
//        return true
//    }
//
//    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
//        if UI_USER_INTERFACE_IDIOM() == .pad {
//            return .all
//        } else {
//            return .allButUpsideDown
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "showDetail" {
            // Get the single item.
            let mapViewController = segue.destination as! MapViewController
            let selectedItemPath = self.tableView.indexPathForSelectedRow!
            let mapItem = self.places[selectedItemPath.row]
            
            // Pass the new bounding region to the map destination view controller.
            var region = self.boundingRegion
            // And center it on the single placemark.
            region.center = mapItem.placemark.coordinate
            mapViewController.boundingRegion = region
            
            // Pass the individual place to our map destination view controller.
            mapViewController.mapItemList = [mapItem]
            
        } else if segue.identifier == "showAll" {
            let mapViewController = segue.destination as! MapViewController
            // Pass the new bounding region to the map destination view controller.
            mapViewController.boundingRegion = self.boundingRegion
            
            // Pass the list of places found to our map destination view controller.
            mapViewController.mapItemList = self.places
        } else if segue.identifier == "toShowPostData" {
            let restaurant = sender as! Restaurant
            
            let vc = segue.destination as! PostInfoViewController
            vc.restaurant = restaurant
        }
    }
    
    
    //MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchResults.count > 0 {
            return searchResults.count
        } else {
            return self.places.count
        }
    }

    
    //mark: - UITableViewDelegate
    //### As far as I know, `tableView(_:cellForRowAt:)` is declared in UITableViewDataSource...

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchResults.count > 0 {
            let searchResult = searchResults[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InfoCell
            if let _ = searchResult.shopID {
                cell.dr.text = "DR"
            } else {
                cell.dr.text = ""
            }
            cell.title.text = searchResult.shopName
            cell.subtitle.text = searchResult.address
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier, for: indexPath)
        
        let mapItem = self.places[indexPath.row]
        cell.textLabel!.text = mapItem.name
        let latitude = mapItem.placemark.coordinate.latitude
        let longitude = mapItem.placemark.coordinate.longitude
        if let phoneNumber = mapItem.phoneNumber {
            cell.detailTextLabel?.text = "\(String(describing:phoneNumber))度\(String(latitude)):\(String(longitude))"
        }
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = searchResults[indexPath.row]
        MoyaProvider<DRApi>().request(.postRestaurant(accessToken: self.appDelegate.accessToken, restaurant: restaurant)) { (result) in
            switch result {
            case .success(let response):
                do{
                    let json = try JSON(data: response.data)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toShowPostData",
                                          sender: restaurant)
                    }
                    print(json)
                } catch let e {
                    print(e)
                }
            case .failure(let error):
                print(error)
            }
        }
//        if isAutoSuggest == true {
//            let titleStr = searchResults[indexPath.row].shopName
//            self.searchController.searchBar.text = titleStr
//        }
    }
    
    //MARK: - UISearchBarDelegate
    
    /*
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if #available(iOS 11.0, *) {
            //### What to do (or what not to do) for UISearchConroller?
        } else {
            // If the text changed, reset the tableview if it wasn't empty.
            if !self.places.isEmpty {
                
                // Set the list of places to be empty.
                self.places = []
                // Reload the tableview.
                self.tableView.reloadData()
                // Disable the "view all" button.
                self.viewAllButton.isEnabled = false
            }
        }
    } */
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchCompleter.queryFragment = "附近的餐廳"
        } else {
            searchCompleter.queryFragment = searchText
        }
        self.searchText = searchText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchRest(completer)
        isAutoSuggest = true
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchCompleter.queryFragment = "附近的餐廳"
        self.searchText = ""
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isAutoSuggest = false
//        let completion = {
//
//            // Check if location services are available
//            guard CLLocationManager.locationServicesEnabled() else {
//                NSLog("%@: location services are not available.", #function)
//
//                // Display alert to the user.
//                let alert = UIAlertController(title: "Location services",
//                                              message: "Location services are not enabled on this device. Please enable location services in Settings.",
//                                              preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .default,
//                                                  handler: nil)
//
//                alert.addAction(defaultAction)
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//
//            // Request "when in use" location service authorization.
//            // If authorization has been denied previously, we can display an alert if the user has denied location services previously.
//            if CLLocationManager.authorizationStatus() == .notDetermined {
//                self.locationManager.requestWhenInUseAuthorization()
//            } else if CLLocationManager.authorizationStatus() == .denied {
//                NSLog("%@: location services authorization was previously denied by the user.", #function)
//
//                // Display alert to the user.
//                let alert = UIAlertController(title: "Location services",
//                                              message: "Location services were previously denied by the user. Please enable location services for this app in Settings.",
//                                              preferredStyle: .alert)
//
//                let settingsAction = UIAlertAction(title: "Settings",
//                    style: .default,
//                    handler: {action in
//                    // Take the user to Settings app to possibly change permission.
//                    let url = URL(string: UIApplicationOpenSettingsURLString)!
//                        if #available(iOS 10.0, *) {
//                            UIApplication.shared.open(url, options: [:],  completionHandler: nil)
//                        } else {
//                            UIApplication.shared.openURL(url)
//                        }
//                    })
//                alert.addAction(settingsAction)
//
//                let defaultAction = UIAlertAction(title: "OK",
//                                                  style: .default,
//                                                  handler: nil)
//                alert.addAction(defaultAction)
//
//                self.present(alert, animated: true, completion: nil)
//                return
//            }
//
//            // Ask for our location.
//            self.locationManager.delegate = self
//            if #available(iOS 9.0, *) {
//                self.locationManager.requestLocation()
//            } else {
//                self.locationManager.startUpdatingLocation()
//            }
//
//            // When a location is delivered to the location manager delegate, the search will
//            // actually take place. See the -locationManager:didUpdateLocations: method.
//        }
        if #available(iOS 11.0, *) {
            self.searchController.dismiss(animated: true, completion: nil)
        } else {
            print("aa")
        }
    }
    
    private func startSearch(_ searchString: String?) {
//        isAutoSuggest = false
//        if self.localSearch?.isSearching ?? false {
//            self.localSearch!.cancel()
//        }
//        SVProgressHUD.show()
//        // Confine the map search area to the user's current location.
//        // Setup the area spanned by the map region.
//        // We use the delta values to indicate the desired zoom level of the map.
//        //
//        let center = CLLocationCoordinate2DMake(self.userCoordinate.latitude, self.userCoordinate.longitude)
//        let newRegion = MKCoordinateRegionMakeWithDistance(center, 12000, 12000)
//
//        let request = MKLocalSearchRequest()
//        request.naturalLanguageQuery = searchString
//        request.region = newRegion
//
//        let completionHandler: MKLocalSearchCompletionHandler = {[weak self] response, error in
//            guard let this = self else {return}
//            if let actualError = error as NSError? {
////                let errorStr = actualError.userInfo[NSLocalizedDescriptionKey] as! String
//                let alert = UIAlertController(title: "Could not find places",
//                                              message: "",
//                                              preferredStyle: .alert)
//                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alert.addAction(ok)
//                this.present(alert, animated: true, completion: nil)
//            } else {
//                this.places = response!.mapItems
//
//                // Used for later when setting the map's region in "prepareForSegue".
//                this.boundingRegion = response!.boundingRegion
//
//                this.viewAllButton.isEnabled = !this.places.isEmpty
//                self?.searchResults = [Restaurant]()
//                this.tableView.reloadData()
//                SVProgressHUD.dismiss()
//            }
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        }
//
//        if self.localSearch != nil {
//            localSearch = nil
//        }
//
//        UIApplication.shared.isNetworkActivityIndicatorVisible = true
//        places = []
//
//        localSearch = MKLocalSearch(request: request)
//        self.localSearch!.start(completionHandler: completionHandler)
    }

    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Remember for later the user's current location.
        let userLocation = locations.last!
        self.userCoordinate = userLocation.coordinate
        
        manager.delegate = nil         // We might be called again here, even though we
        // called "stopUpdatingLocation", so remove us as the delegate to be sure.
        
        // We have a location now, so start the search.
        self.searchCompleter.queryFragment = "附近的餐廳"
//        if #available(iOS 11.0, *) {
//            searchCompleter.queryFragment = "附近的餐廳"
//        } else {
//            searchCompleter.queryFragment = "附近的餐廳"
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // report any errors returned back from Location Services
    }
    
    
    func searchRest(_ completer: MKLocalSearchCompleter) {
        let latitude = "25.033671"
        let longitude = "121.564427"
        var parameter = [String:String]()

        if localSwitch.isOn {
            parameter["latitude"] = latitude
            parameter["longitude"] = longitude
            
        }
        parameter["filter"] = self.searchText ?? ""
        
        MoyaProvider<DRApi>().request(.getAutoComplete(accessToken: self.appDelegate.accessToken, parameter: parameter)) { (result) in
            self.searchResults.removeAll()
            for result in completer.results {
                
                let rest = Restaurant(shopID: nil, shopName: result.title, address: result.subtitle)
                self.searchResults.append(rest)
            }
            switch result {
            case .success(let response):
                do{
                    let json = try JSON(data: response.data)
                    let restaurantResult = try JSONDecoder.init().decode(CommonResult<[Restaurant]>.self, from: response.data)
                    if let restaurants = restaurantResult.restaurantData {
                        self.searchResults = self.searchResults + restaurants
//                        self.searchResults = restaurants + self.searchResults
                    }
                } catch let e {
                    print(e)
                }
            case .failure(let error):
                print(error)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
}

class CommonResult<T: Codable>: Decodable {
    var statusCode: Int?
    var statusMsg: String?
    var restaurantData: T?
}

class InfoCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var dr: UILabel!
    
}
