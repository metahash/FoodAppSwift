//
//  DriverOrder.swift
//  FoodApp
//
//  Created by Victor.
//  Copyright © 2017 Victor. All rights reserved.
//

import Foundation
import SwiftyJSON

class DriverOrder {
    
    var id: Int?
    var customerName: String?
    var customerAddress: String?
    var customerAvatar: String?
    var restaurantName: String?
    
    init(json: JSON) {
        
        self.id = json["id"].int
        self.customerName = json["customer"]["name"].string
        self.customerAddress = json["address"].string
        self.customerAvatar = json["cuscustomer"]["avatar"].string
        self.restaurantName = json["restaraunt"]["name"].string
    }
    
}
