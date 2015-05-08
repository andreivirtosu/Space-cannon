import SpriteKit

class GameScore: SKNode {
  
  var scoreLabel = SKLabelNode(fontNamed: "DIN Alternate")
  var pointMultiplierLabel = SKLabelNode(fontNamed: "DIN Alternate")
  
  override var hidden:Bool {
    didSet {
      scoreLabel.hidden = hidden
      pointMultiplierLabel.hidden = hidden
    }
  }
  
  
  var score:Int = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  var pointMultiplier:Int = 1 {
    didSet {
      pointMultiplierLabel.text = "Point value: x\(pointMultiplier)"
    }
  }
  
  override init() {
    super.init()
    
    ({ () -> Void in
      self.score = 0
      self.pointMultiplier = 1
    })()
    
    scoreLabel.position = CGPointMake(0, 0)
    scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
    scoreLabel.fontSize = 15
    addChild(scoreLabel)
    
    pointMultiplierLabel.position = CGPointMake(0, 20)
    pointMultiplierLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
    pointMultiplierLabel.fontSize = 15
    addChild(pointMultiplierLabel)
  }
  
  func updateScore() {
    score += pointMultiplier
  }
  
  func updateScoreForMultiplier() {
    updateScore()
    ++pointMultiplier
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
}
