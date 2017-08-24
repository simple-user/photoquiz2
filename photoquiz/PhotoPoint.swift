//
//  PhotoPoint.swift
//  photoquiz
//
//  Created by Oleksandr on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class PhotoPoint: NSObject, MKAnnotation {

    var coordinate: CLLocationCoordinate2D

    let id: String
    var isTruePoint: Bool

    init(pointId: String, location: CLLocationCoordinate2D, isTruePoint: Bool = false) {
        id = pointId
        coordinate = location
        self.isTruePoint = isTruePoint
        super.init()
    }

}
