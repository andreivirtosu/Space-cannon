//
//  GameMenu.swift
//  Space cannon
//
//  Created by Andrei Virtosu on 03/05/15.
//  Copyright (c) 2015 Andrei Virtosu. All rights reserved.
//

import Foundation
import SpriteKit

class GameMenu: SKNode {
  
  let title = SKSpriteNode(imageNamed: "Title")
  let scoreBoard = SKSpriteNode(imageNamed: "ScoreBoard")
  let playButton = SKSpriteNode(imageNamed: "PlayButton")
  let scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
  let topScoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
  let topScoreKey = "TopScore"
  
  var userDefaults = NSUserDefaults.standardUserDefaults()
  
  internal var topScore:Int = 0 {
    didSet {
      topScoreLabel.text = "\(self.topScore)"
      userDefaults.setInteger(topScore, forKey: topScoreKey)
    }
  }
  
  internal var score:Int = 0 {
    didSet {
      scoreLabel.text = "\(self.score)"
      topScore = max(topScore, score)
    }
  }
  
  override init() {
    super.init()
    
    ({ () -> Void in
      self.topScore = self.userDefaults.integerForKey(self.topScoreKey)
      self.score = 0
    })()
    
    title.position = CGPointMake(0, 140)
    addChild(title)
    
    scoreBoard.position = CGPointMake(0, 70)
    addChild(scoreBoard)
    
    playButton.position = CGPointZero;
    playButton.name = "Play"
    addChild(playButton)
    
    scoreLabel.fontSize = 30;
    scoreLabel.position = CGPointMake(-52, 50)
    topScoreLabel.fontSize = 30;
    topScoreLabel.position = CGPointMake(48, 50)
    
    addChild(scoreLabel)
    addChild(topScoreLabel)
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}