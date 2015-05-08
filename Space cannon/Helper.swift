//
//  Helper.swift
//  Space cannon
//
//  Created by Andrei Virtosu on 02/05/15.
//  Copyright (c) 2015 Andrei Virtosu. All rights reserved.
//

import Foundation
import UIKit

struct Helper
{

  static func radiansToVector(radians: CGFloat) -> CGVector 
  {
    var dx = cos(radians)
    var dy = sin(radians)
    
    var vector = CGVectorMake(dx, dy)
    return vector
  }
  
  static func randomInRange(low:CGFloat, high:CGFloat ) -> CGFloat {
    
    let val:CGFloat = CGFloat(arc4random_uniform(UINT32_MAX)) / CGFloat(UINT32_MAX)
    return val * (high-low) + low
  }
  
}