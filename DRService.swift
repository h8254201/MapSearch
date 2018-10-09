//
//  DRService.swift
//  MapSearch
//
//  Created by Peter Yo on Oct/5/18.
//

import Foundation
import Moya

enum DRApi {
    case login(email:String, password: String)
    case postRestaurant(accessToken: String, restaurant: Restaurant)
    case getAutoComplete(accessToken: String,
        latitude: String,
        longitude: String,
        filter: String)
}

extension DRApi : TargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://api.larvatadish.work/") else {
            fatalError("baseURL could not be configured")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .getAutoComplete:
            return "/app/restaurants"
        case .postRestaurant:
            return "/app/v1/reviews/restaurant/review"
        case .login:
            return "/app/login"
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
        case .getAutoComplete(let accessToken,
                              let latitude,
                              let longitude,
                              let filter):
            
            return .requestJSONEncodable(["latitude": latitude,
                                          "longitude" : longitude,
                                          "filter" : filter,
                                          "accessToken": accessToken])
        case .postRestaurant(_, let restaurant):
            let rest = Rest(rest: restaurant)
//            var parameters: [String: Any] = ["accessToken": ""]
//            var rreview: [String: Any] = [:]
//            rreview["restaurantID"] = restaurant.id
//            rreview["shopName"] = restaurant.shopName
//            rreview["address"] = restaurant.address
//            parameters["restaurantReview"] = rreview
//            parameters["dishReview"] = []
//            parameters["otherReview"] = []
//            parameters["shareType"] = 1
            
            return .requestJSONEncodable(rest)
//            return .requestParameters(parameters: parameters,
//                                      encoding: URLEncoding.default)
        case .login(let email, let password):
            return .requestParameters(parameters: ["email": email,
                                                   "password" : password],
                                      encoding: URLEncoding.default)
            
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getAutoComplete(let accessToken, _, _, _):
            return ["Content-Type": "application/json",
                    "Accept": "application/json",
//                    "Authorization": "Bearer " + accessToken
            ]
        case .postRestaurant(let accessToken, _):
            return ["Content-Type": "application/json",
                    "Authorization": "Bearer " + accessToken]
        default:
            return nil
        }
    }
    
    
}

class Rest: Encodable {
    var restaurantReview: Restaurant
    var dishReview: Array<Int>
    var otherReview: Array<Int>
    var shareType: Int
    init(rest: Restaurant){
        self.restaurantReview = Restaurant(shopID: rest.shopID,
                                           shopName: rest.shopName,
                                           address: rest.address)
        self.dishReview = []
        self.otherReview = []
        shareType = 1
    }

}
