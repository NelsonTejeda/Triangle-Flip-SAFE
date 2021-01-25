//
//  randomFunc.swift
//  Triangle Flip
//
//  Created by Nelson Tejeda on 8/7/17.
//  Copyright © 2017 Nu Seble Games. All rights reserved.
//

import Foundation
import CoreGraphics

public extension CGFloat{

    public static func random() -> CGFloat{
        
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    public static func random(min : CGFloat, max : CGFloat) -> CGFloat{
        
        return CGFloat.random() * (max - min) + min
    }
}
