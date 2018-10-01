//
//  FBTestViewController.swift
//  MapSearch
//
//  Created by Peter Yo on Oct/1/18.
//

import UIKit
import FBSDKPlacesKit
import SVProgressHUD
import MapKit

class FBTestViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    var placesManager = FBSDKPlacesManager()
    var locManager = CLLocationManager()
    var mapItem: MKMapItem?
    var cursorString = ""
    @IBOutlet weak var categorySwitch: UISwitch!
    @IBOutlet weak var dataTableView: UITableView!
    var dataArray = Array<Dictionary<String,Any>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataTableView.rowHeight = UITableViewAutomaticDimension
        dataTableView.estimatedRowHeight = 50
        dataTableView.delegate = self
        dataTableView.dataSource = self
    }
    
    @IBAction func search(_ sender: UIButton) {
        SVProgressHUD.show()
        
        var categories = [String]()
        if categorySwitch.isOn {
            categories = ["FOOD_BEVERAGE"]
        }
        
        let lati = self.mapItem?.placemark.coordinate.latitude
        let longi = self.mapItem?.placemark.coordinate.longitude
        let appleLocation = CLLocation(latitude: lati!, longitude: longi!)
        let graphRequest = placesManager.placeSearchRequest(for: appleLocation,
                                                            searchTerm: mapItem?.name,
                                                            categories: categories,
                                                            fields: [FBSDKPlacesFieldKeyPhone,
                                                                     FBSDKPlacesFieldKeyAbout,
                                                                     FBSDKPlacesFieldKeyName,
                                                                     FBSDKPlacesFieldKeyCoverPhoto,
                                                                     FBSDKPlacesFieldKeyLocation,
                                                                     FBSDKPlacesFieldKeyCategories],
                                                            distance: 5000,
                                                            cursor: nil)
        
        _ = graphRequest?.start(completionHandler: { (connection, result, error) in
            if let resultDic = result as? Dictionary<String,Any> {
                if let dataArray = resultDic["data"] as? Array<Dictionary<String,Any>> {
                    self.dataArray = dataArray
                    DispatchQueue.main.async {
                        self.dataTableView.reloadData()
                        SVProgressHUD.dismiss()
                    }
                    for data in dataArray {
                        let name = data["name"] as! String
                        print(name)
                        
                    }
                }
                if let paging = resultDic["paging"] as? Dictionary<String,Any>,
                    let cursors = paging["cursors"] as? Dictionary<String,Any>,
                    let cursorString = cursors["after"] as? String {
                    self.cursorString = cursorString
                } else {
                    self.cursorString = ""
                }
            }
            
            
            
            
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FBCell", for: indexPath) as! FBTableviewCell
        let dataDic = dataArray[indexPath.row]
        cell.categoriesText.text = ""
        cell.restNameLabel.text = dataDic["name"] as? String
        let categories = dataDic["category_list"] as? Array<Dictionary<String,Any>> ?? []
        for category in categories {
            cell.categoriesText.text = cell.categoriesText.text + "\n" + (category["name"] as! String)
        }
        return cell

    }

    
}

class FBTableviewCell: UITableViewCell {
    @IBOutlet weak var restNameLabel: UILabel!
    @IBOutlet weak var categoriesText: UITextView!
}
