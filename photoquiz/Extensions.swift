//
//  Extensions.swift
//  photoquiz
//
//  Created by BUDDAx2 on 8/12/17.
//  Copyright © 2017 Rivne Hackathon. All rights reserved.
//

import Foundation
import UIKit


extension MutableCollection where Index == Int {
    /// Shuffle the elements of `self` in-place.
    mutating func shuffle() {
        // empty and single-element collections don't shuffle
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                swap(&self[i], &self[j])
            }
        }
    }
}

extension Collection {
    /// Return a copy of `self` with its elements shuffled
    func shuffled() -> [Iterator.Element] {
        var list = Array(self)
        list.shuffle()
        return list
    }
}

extension UIImage {
    var uncompressedPNGData: Data?      { return UIImagePNGRepresentation(self)        }
    var highestQualityJPEGNSData: Data? { return UIImageJPEGRepresentation(self, 1.0)  }
    var highQualityJPEGNSData: Data?    { return UIImageJPEGRepresentation(self, 0.75) }
    var mediumQualityJPEGNSData: Data?  { return UIImageJPEGRepresentation(self, 0.5)  }
    var lowQualityJPEGNSData: Data?     { return UIImageJPEGRepresentation(self, 0.25) }
    var lowestQualityJPEGNSData:Data?   { return UIImageJPEGRepresentation(self, 0.0)  }
}
