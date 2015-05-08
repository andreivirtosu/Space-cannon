//
//  GameBall.swift
//  Space cannon
//
//  Created by Andrei Virtosu on 04/05/15.
//  Copyright (c) 2015 Andrei Virtosu. All rights reserved.
//

import Foundation
import SpriteKit

class GameBall: SKSpriteNode {
  
  internal var trail:SKEmitterNode?
  internal var bounces:Int32 = 0
  
  
  func updateTrail() {
    if let t = trail {
      t.position = self.position
    }
  }
  
  override func removeFromParent() {
    if let t = trail {
      t.particleBirthRate = CGFloat(0.0)
      let delay:Double = Double(t.particleLifetime) + Double(t.particleLifetimeRange)
      let removeTrail = SKAction.sequence([SKAction.waitForDuration(delay), SKAction.removeFromParent()])
      
      t.runAction(removeTrail)
    }
    
    super.removeFromParent()
  }
}