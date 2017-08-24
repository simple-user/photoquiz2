//
//  PhotoDBModel.swift
//  photoquiz
//
//  Created by BUDDAx2 on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON


struct PhotoDBModel {
    
    let id: String
    let path: String
    let location: CLLocationCoordinate2D
    
    init(json: JSON) {
        
        id = json["id"].stringValue
        path = json["path"].stringValue

        let lat = json["location"]["lat"].doubleValue
        let lon = json["location"]["lon"].doubleValue
        location = CLLocationCoordinate2DMake(lat, lon)
    }
}
