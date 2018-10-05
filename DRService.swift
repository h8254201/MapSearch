//
//  DRService.swift
//  MapSearch
//
//  Created by Peter Yo on Oct/5/18.
//

import Foundation
import Moya

enum DRApi {
    case postRestaurant(restaurant: Restaurant)
}

extension DRApi : TargetType {
    var baseURL: URL {
        guard let url = URL(string: "https://") else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .postRestaurant:
                return "restaurant"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return sampleData
    }
    
    var task: Task {
        switch self {
        case .postRestaurant(let restaurant):
            return .requestJSONEncodable(restaurant)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}
