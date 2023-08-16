//
//  randomFunction.swift
//  Up
//
//  Created by Pravangasta Suihangya Balqis Wahyudi on 11/08/23.
//

import Foundation
import CoreGraphics

public extension CGFloat{
    
    
    static func random() -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
    
    
}
