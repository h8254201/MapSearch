//
//  PostInfoViewController.swift
//  MapSearch
//
//  Created by 朱紹翔 on 2018/10/9.
//

import UIKit

class PostInfoViewController: UIViewController {
    @IBOutlet weak var showInfoText: UITextView!
    var restaurant: Restaurant?
    override func viewDidLoad() {
        super.viewDidLoad()
        let restID = (restaurant?.shopID?.description ?? "沒有ID") == "" ? "沒有ID" : restaurant?.shopID?.description ?? "沒有ID"
        
        let restName = (restaurant?.shopName ?? "沒有名稱") == "" ? "沒有名稱" : restaurant?.shopName ?? "沒有名稱"
        
        let restAddress = (restaurant?.address ?? "沒有地址") == "" ? "沒有地址" : restaurant?.address ?? "沒有地址"
        
        var isDr = "是"
        
        if restID == "沒有ID" {
            isDr = "否"
        }
        
        showInfoText.text = "restaurantID: \(restID)"
            + "\n\nrestaurantName: \(restName)"
            + "\n\nrestaurantAddress: \(restAddress)"
            + "\n\n是否為DR餐廳: \(isDr)"
            + "\n\n是否找到餐廳要在後台log才能顯示"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
