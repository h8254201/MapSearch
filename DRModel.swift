//
//  DRModel.swift
//  MapSearch
//
//  Created by Peter Yo on Oct/5/18.
//

import Foundation

struct Restaurant: Codable {
    let shopID: Int?
    let shopName: String
    let address: String
    init(shopID: Int?, shopName: String, address: String){
        self.shopID = shopID
        self.shopName = shopName
        self.address = address
    }
}
