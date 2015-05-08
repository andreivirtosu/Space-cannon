import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  let SHOOT_SPEED:CGFloat = 1000.0
  let HALO_LOW_ANGLE = CGFloat(200.0 * M_PI / 180)
  let HALO_HIGH_ANGLE = CGFloat(340.0 * M_PI / 180)
  let HALO_SPEED = CGFloat(100.0)
  
  let HaloCategory:uint = 0x1 << 0
  let BallCategory:uint = 0x1 << 1
  let EdgeCategory:uint = 0x1 << 2
  let ShieldCategory:uint = 0x1 << 3
  let LifeBarCategory:uint = 0x1 << 4
  let MultiShotPowerUpCategory:uint = 0x1 << 5
  
  let soundAction = SoundAction()
  
  var mainLayer = SKNode()
  var cannon = SKSpriteNode(imageNamed: "Cannon")
  var ammoDisplay = SKSpriteNode(imageNamed: "Ammo5")
  var menu = GameMenu()
  var gameScore = GameScore()
  
  var isGameOver = true {
    didSet {
      menu.hidden = !isGameOver
      gameScore.hidden = isGameOver
      
      if !isGameOver {
        halosKilled = 0
        multiShotMode = false
        actionForKey("createHalo")?.speed = 1.0
        gameScore.score = 0
        menu.score = 0
      } else {
        menu.score = gameScore.score
      }
      
    }
  }
  
  var ammo:Int = 5 {
    didSet {
      ammo = max(0,min(ammo, 5))
      ammoDisplay.texture = SKTexture(imageNamed: "Ammo\(ammo)")
      if ammo == 0 && multiShotMode {
        multiShotMode = false
      }
    }
  }
  
  var halosKilled:Int = 0 {
    didSet {
      if halosKilled == 10 {
        halosKilled = 0
        createMultiShotPowerUp()
      }
    }
  }
  
  var multiShotMode = false {
    didSet {
      if (oldValue == multiShotMode) {
        return
      }
      self.ammo = 5
      
      if (multiShotMode) {
        cannon.texture = SKTexture(imageNamed: "GreenCannon")
        self.actionForKey("incrementAmo")?.speed = 0 // pause normal mode increment
      } else {
        self.actionForKey("incrementAmo")?.speed = 1.0    // revert to normal mode increment
        cannon.texture = SKTexture(imageNamed: "Cannon")
      }
    }
  }
  
  var didShoot = false
  
  override func didMoveToView(view: SKView) {
    /* Setup your scene here */
    
    self.physicsWorld.gravity = CGVectorMake(0.0, 0.0)
    self.physicsWorld.contactDelegate = self
    
    var bg = SKSpriteNode(imageNamed: "Starfield")
    bg.blendMode = SKBlendMode.Replace
    bg.anchorPoint = CGPointZero
    bg.position = CGPointZero
    self.size = CGSizeMake(bg.size.width, bg.size.height)
    self.addChild(bg)
    
    var leftEdge = SKSpriteNode()
    leftEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: CGPointMake(0.0, self.size.height + 100))
    leftEdge.position = CGPointZero
    leftEdge.physicsBody?.categoryBitMask = EdgeCategory
    addChild(leftEdge)
    
    var rightEdge = SKSpriteNode()
    rightEdge.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointZero, toPoint: CGPointMake(0.0, self.size.height + 100))
    rightEdge.position = CGPointMake(self.size.width, 0.0 )
    rightEdge.physicsBody?.categoryBitMask = EdgeCategory
    addChild(rightEdge)
    
    cannon.position = CGPointMake(self.size.width / 2, 0)
    self.addChild(cannon)
    self.addChild(mainLayer)
    
    let rotateCannon = SKAction.sequence([SKAction.rotateByAngle( CGFloat(M_PI), duration: 2),
      SKAction.rotateByAngle(CGFloat(-M_PI), duration: 2)])
    cannon.runAction(SKAction.repeatActionForever(rotateCannon))
    
    let haloAction = SKAction.sequence([SKAction.waitForDuration(2, withRange: 1),
      SKAction.runBlock({ self.createHalo() })
      ])
    runAction(SKAction.repeatActionForever(haloAction), withKey: "createHalo")
    
    let haloSpeedUpdateAction = SKAction.sequence([SKAction.waitForDuration(2.0),
      SKAction.runBlock({ self.increaseHaloSpawningSpeed() })
      ])
    runAction(SKAction.repeatActionForever(haloSpeedUpdateAction))
    
    gameScore.position = CGPointMake(15, 10)
    addChild(gameScore)
    
    ammoDisplay.anchorPoint = CGPointMake(0.5, 0.0)
    ammoDisplay.position = cannon.position
    self.addChild(ammoDisplay)
    
    var incrementAmmo = SKAction.sequence([SKAction.waitForDuration(1),
      SKAction.runBlock({ self.ammo++; })])
    self.runAction(SKAction.repeatActionForever(incrementAmmo), withKey: "incrementAmo")
    
    menu.position = CGPointMake(self.size.width * 0.5, self.size.height - 220)
    addChild(menu)
    
    isGameOver = true
  }
  
  func increaseHaloSpawningSpeed() {
    var action = self.actionForKey("createHalo")!
    if action.speed < 1.5 {
      action.speed += 0.01
    }
  }
  
  func createMultiShotPowerUp() {
    var node = SKSpriteNode(imageNamed: "MultiShotPowerUp")
    node.name = "multipowerup"
    node.position = CGPointMake( -node.size.width, Helper.randomInRange(150.0, high: self.size.height - 100))
    node.physicsBody = SKPhysicsBody(circleOfRadius: 12)
    node.physicsBody?.linearDamping = 0.0
    node.physicsBody?.friction = 0.0
    node.physicsBody?.velocity = CGVectorMake(100.0, Helper.randomInRange(-40, high: 40))
    node.physicsBody?.restitution = 0.0
    node.physicsBody?.affectedByGravity = false
    node.physicsBody?.angularVelocity = CGFloat(M_PI)
    node.physicsBody?.collisionBitMask = 0
    node.physicsBody?.contactTestBitMask = BallCategory
    node.physicsBody?.categoryBitMask = MultiShotPowerUpCategory
    mainLayer.addChild(node)
  }
  
  func newGame() {
    isGameOver = false
    mainLayer.removeAllChildren()
    createShields()
    createLifeBar()
  }
  
  func createLifeBar() {
    var lifeBar = SKSpriteNode(imageNamed: "BlueBar")
    lifeBar.position = CGPointMake(self.size.width * 0.5, 70)
    lifeBar.physicsBody = SKPhysicsBody(edgeFromPoint: CGPointMake(-lifeBar.size.width * 0.5, 0), toPoint: CGPointMake(lifeBar.size.width * 0.5, 0))
    lifeBar.physicsBody?.categoryBitMask = LifeBarCategory
    mainLayer.addChild(lifeBar)
  }
  
  func createShields() {
    for i in 0...5 {
      var shield = SKSpriteNode(imageNamed: "Block")
      shield.name = "shield"
      shield.position = CGPointMake( CGFloat(35+i*50), 90.0)
      shield.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(42, 9))
      shield.physicsBody?.categoryBitMask = ShieldCategory
      shield.physicsBody?.collisionBitMask = 0
      mainLayer.addChild(shield)
    }
  }
  
  func addExplosion(position:CGPoint, explosionName: String) {
    let path = NSBundle.mainBundle().pathForResource(explosionName, ofType: "sks")!
    let explosion = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! SKEmitterNode
    
    explosion.position = position
    mainLayer.addChild(explosion)
    
    let removeExplosion = SKAction.sequence([SKAction.waitForDuration(1.5), SKAction.removeFromParent()])
    explosion.runAction(removeExplosion)
  }
  
  private func createHalo() {
    var halo = SKSpriteNode(imageNamed: "Halo")
    halo.name = "halo"
    halo.physicsBody = SKPhysicsBody(circleOfRadius: halo.size.width/2)
    halo.position = CGPointMake(
      Helper.randomInRange( halo.size.width * 0.5, high:self.size.width - (halo.size.width*0.5)),
      self.size.height + (halo.size.width*0.5))
    let direction = Helper.radiansToVector(Helper.randomInRange(HALO_LOW_ANGLE, high: HALO_HIGH_ANGLE))
    halo.physicsBody?.velocity = CGVectorMake(direction.dx * HALO_SPEED , direction.dy * HALO_SPEED)
    halo.physicsBody?.restitution = 1.0
    halo.physicsBody?.linearDamping = 0.0
    halo.physicsBody?.friction = 0.0
    halo.physicsBody?.categoryBitMask = HaloCategory
    halo.physicsBody?.collisionBitMask = EdgeCategory
    halo.physicsBody?.contactTestBitMask = BallCategory | ShieldCategory | LifeBarCategory | EdgeCategory
    
    if isBombPowerUpCondition() {
      halo.texture = SKTexture(imageNamed: "HaloBomb")
      halo.userData = ["Bomb": true]
      
    } else if isRandomPointMultiplierCondition() {
      halo.texture = SKTexture(imageNamed: "HaloX")
      halo.userData = [ "Multiplier": true]
    }
    mainLayer.addChild(halo)
  }
  
  func isRandomPointMultiplierCondition() -> Bool {
    // game ongoing and 1/6 probability
    return !isGameOver && arc4random_uniform(6) == 0
  }
  
  func isBombPowerUpCondition() -> Bool {
    // At least 4 halos are on the screen, and no other bombs present
    var activeHalos = 0
    mainLayer.enumerateChildNodesWithName("halo", usingBlock: { (node:SKNode!, stop:UnsafeMutablePointer<ObjCBool>) in
      if node.userData?.valueForKey("Bomb") == nil {
        ++activeHalos
      }
    })
    return activeHalos >= 4
  }
  
  func didBeginContact(contact: SKPhysicsContact) {
    var first = contact.bodyA
    var second = contact.bodyB
    
    if first.categoryBitMask > second.categoryBitMask {
      swap( &first, &second)
    }
    
    if first.categoryBitMask == HaloCategory && second.categoryBitMask == BallCategory {
      if let mulitplier = first.node?.userData?.valueForKey("Multiplier") as? Bool {
        gameScore.updateScoreForMultiplier()
      }
      else {
        gameScore.updateScore()
      }
      
      if let pos = first.node?.position {
        addExplosion(pos, explosionName: "HaloExplosion")
        ++halosKilled
      }
      
      if let bomb = first.node?.userData?.valueForKey("Bomb") as? Bool {
        mainLayer.enumerateChildNodesWithName("halo", usingBlock: { (node:SKNode!, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
          self.addExplosion(node.position, explosionName: "HaloExplosion")
          ++self.halosKilled
          node.removeFromParent()
          self.runAction(self.soundAction.explosion)
        })
      }
      
      first.categoryBitMask = 0
      first.node?.removeFromParent()
      second.node?.removeFromParent()
      self.runAction(soundAction.explosion)
    }
    else
      if first.categoryBitMask == HaloCategory && second.categoryBitMask == ShieldCategory {
        addExplosion(first.node!.position, explosionName: "HaloExplosion")
        first.categoryBitMask = 0
        first.node?.removeFromParent()
        second.node?.removeFromParent()
      }
      else
        if first.categoryBitMask == HaloCategory && second.categoryBitMask == LifeBarCategory {
          addExplosion(first.node!.position, explosionName: "HaloExplosion")
          addExplosion(contact.contactPoint, explosionName: "LifeBarExplosion")
          second.node?.removeFromParent()
          self.runAction(soundAction.deepExplosion)
          gameOver()
        }
        else
          if first.categoryBitMask == BallCategory && second.categoryBitMask == EdgeCategory {
            if let ball = first.node as? GameBall {
              ball.bounces++
              if ball.bounces > 3 {
                first.node?.removeFromParent()
                gameScore.pointMultiplier = 1
              }
            }
            addExplosion(contact.contactPoint, explosionName: "EdgeExplosion")
            self.runAction(soundAction.bounce)
            
          }
          else
            if first.categoryBitMask == HaloCategory && second.categoryBitMask == EdgeCategory {
              self.runAction(soundAction.zap)
            }
            else
              if first.categoryBitMask == BallCategory && second.categoryBitMask == MultiShotPowerUpCategory {
                multiShotMode = true
                first.node?.removeFromParent()
                second.node?.removeFromParent()
                
    }
    
  }
  
  func gameOver() {
    mainLayer.enumerateChildNodesWithName("halo", usingBlock: { (node:SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      self.addExplosion(node.position, explosionName: "HaloExplosion")
      node.removeFromParent()
    })
    
    mainLayer.enumerateChildNodesWithName("ball", usingBlock: { (node:SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      node.removeFromParent()
    })
    
    mainLayer.enumerateChildNodesWithName("shield", usingBlock: { (node:SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      self.addExplosion(node.position, explosionName: "HaloExplosion")
      node.removeFromParent()
    })
    
    isGameOver = true
  }
  
  func shoot() {
    var ball = GameBall(imageNamed: "Ball")
    ball.name = "ball"
    var vector = Helper.radiansToVector(cannon.zRotation)
    ball.position = CGPointMake(cannon.position.x + (cannon.size.width/2 * vector.dx),
      cannon.position.y + (cannon.size.width/2 * vector.dy))
    ball.physicsBody = SKPhysicsBody(circleOfRadius: 6.0)
    ball.physicsBody?.velocity =  CGVectorMake(vector.dx * SHOOT_SPEED, vector.dy * SHOOT_SPEED)
    ball.physicsBody?.restitution = 1.0
    ball.physicsBody?.linearDamping = 0.0
    ball.physicsBody?.friction = 0.0
    ball.physicsBody?.categoryBitMask = BallCategory
    ball.physicsBody?.collisionBitMask = EdgeCategory
    ball.physicsBody?.contactTestBitMask = EdgeCategory
    mainLayer.addChild(ball)
    self.runAction(soundAction.laser)
    
    // create trail
    let path = NSBundle.mainBundle().pathForResource("BallTrail", ofType: "sks")!
    let ballTrail = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as! SKEmitterNode
    ballTrail.targetNode = mainLayer
    ball.trail = ballTrail
    mainLayer.addChild(ballTrail)
  }
  
  override func didSimulatePhysics() {
    if didShoot && self.ammo > 0 {
      
      if multiShotMode {
        // shoot 5 times with 0.1sec delay
        var shootAction = SKAction.sequence([SKAction.waitForDuration(0.1), SKAction.runBlock({ self.shoot() })])
        self.runAction( SKAction.repeatAction(shootAction, count: 5))
      } else {
        shoot()
      }
      
      --self.ammo
      didShoot = false
    }
    
    mainLayer.enumerateChildNodesWithName("ball", usingBlock: { (node:SKNode!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
      if let ball = node as? GameBall {
        ball.updateTrail()
      }
      if !CGRectContainsPoint(self.frame, node.position) {
        node.removeFromParent()
        self.gameScore.pointMultiplier = 1
      }
    })
    
    mainLayer.enumerateChildNodesWithName("halo", usingBlock: { (node:SKNode!, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
      if (node.position.y + node.frame.size.height < 0) {
        node.removeFromParent()
      }
    })
  }
  
  override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
    /* Called when a touch begins */
    
    for touch in (touches as! Set<UITouch>) {
      if !isGameOver {
        didShoot = true
      }
    }
  }
  
  override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
    
    for touch in (touches as! Set<UITouch>) {
      if isGameOver {
        let node = menu.nodeAtPoint(touch.locationInNode(menu))
        if node.name == "Play" {
          newGame()
        }
      }
    }
    
  }
  
  override func update(currentTime: CFTimeInterval) {
    /* Called before each frame is rendered */
  }
}
