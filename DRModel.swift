//
//  DRModel.swift
//  MapSearch
//
//  Created by Peter Yo on Oct/5/18.
//

import Foundation

struct Restaurant: Codable {
    let id: Int?
    let shopName: String
    let address: String
    init(id: Int?, shopName: String, address: String){
        self.id = id
        self.shopName = shopName
        self.address = address
    }
}
