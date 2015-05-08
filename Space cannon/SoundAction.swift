//
//  SoundAction.swift
//  Space cannon
//
//  Created by Andrei Virtosu on 03/05/15.
//  Copyright (c) 2015 Andrei Virtosu. All rights reserved.
//

import Foundation
import SpriteKit

struct SoundAction {
  let bounce = SKAction.playSoundFileNamed("Bounce.caf", waitForCompletion: false)
  let deepExplosion = SKAction.playSoundFileNamed("DeepExplosion.caf", waitForCompletion: false)
  let explosion = SKAction.playSoundFileNamed("Explosion.caf", waitForCompletion: false)
  let laser = SKAction.playSoundFileNamed("Laser.caf", waitForCompletion: false)
  let zap = SKAction.playSoundFileNamed("Zap.caf", waitForCompletion: false)
}