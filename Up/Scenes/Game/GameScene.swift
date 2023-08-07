//
//  GameScene.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene {
    
    var starField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let difficultManager = DifficultyManager()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let torpedoSoundAction: SKAction = SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false)
    var gameTimer: Timer!
    var attackers1 = ["red_1","yellow_1","green_1","blue_1","purple_1","pink_1","orange_1"]
    var attackers2 = ["red_1","yellow_1","green_1","blue_1","purple_1","pink_1","orange_1"]
    let balloonCategory: UInt32 = 0x1 << 1
    let torpedoCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var livesArray: [SKSpriteNode]!
    
    let userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        setupLives()
        setupStarField()
        setupPlayer()
        setupPhisicsWord()
        setupScoreLabel()
        setupBalloons()
        setupCoreMotion()
    }
    
    func updateScore(playerNode: SKSpriteNode, balloonNode: SKSpriteNode) {
         let playerMaxY = playerNode.position.y + playerNode.size.height / 2
         let balloonMinY = balloonNode.position.y - balloonNode.size.height / 2
         
         if playerMaxY > balloonMinY {
             score += 1 // Update the score when spaceship passes through a balloon
         }
     }
    
    func setupLives() {
        livesArray = [SKSpriteNode]()
        for life in 1...3 {
            let lifeNode = SKSpriteNode(imageNamed: "spaceship")
            lifeNode.size = CGSize(width: 44, height: 44)
            lifeNode.zPosition = 5
            lifeNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - life) * lifeNode.size.width, y: frame.size.height - 50)
            self.addChild(lifeNode)
            livesArray.append(lifeNode)
        }
        
    }
    
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.10 + self.xAcceleration * 0.10
            }
            
        }
    }
    
    func setupPhisicsWord() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        backgroundColor = .black
    }
    
    func setupStarField() {
        starField = SKEmitterNode(fileNamed: "Starfield")
        
        starField.position = CGPoint(x: 0, y: self.frame.maxY)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
    }
    
    func setupPlayer() {
        player = SKSpriteNode(imageNamed: "spaceship")
        player.size = CGSize(width: 80, height: 80)
        player.position = CGPoint(x: frame.size.width / 2, y: player.size.height / 2 + 20)
        addChild(player)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: (scoreLabel.frame.width / 2) + 10, y: frame.size.height - 50)
        scoreLabel.zPosition = 5
        scoreLabel.fontSize = 25
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.color = .white
        addChild(scoreLabel)
    }
    
    func setupBalloons() {
        let timeInterval = difficultManager.getBalloonAparitionInterval()
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addBalloons), userInfo: nil, repeats: true)
    }
    
    @objc func addBalloons() {
        //Shuffled array of attackers
        attackers1 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: attackers1) as! [String]
        let attaker1 = SKSpriteNode(imageNamed: attackers1[0])
        let attakerPosition1 = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width)/2)
        let position1 = CGFloat(attakerPosition1.nextInt())
        attaker1.size = CGSize(width: 60, height: 60)
        attaker1.position = CGPoint(x: position1, y: frame.size.height + attaker1.size.height)
        attaker1.physicsBody = SKPhysicsBody(circleOfRadius: attaker1.size.width/2)
        
        attaker1.physicsBody?.categoryBitMask = balloonCategory
        attaker1.physicsBody?.contactTestBitMask = torpedoCategory
        attaker1.physicsBody?.collisionBitMask = 0
        
        addChild(attaker1)
        
        attackers2 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: attackers2) as! [String]
        let attaker2 = SKSpriteNode(imageNamed: attackers2[0])
        let attakerPosition2 = GKRandomDistribution(lowestValue: Int(frame.size.width)/2, highestValue: Int(frame.size.width))
        let position2 = CGFloat(attakerPosition2.nextInt())
        attaker2.size = CGSize(width: 60, height: 60)
        attaker2.position = CGPoint(x: position2, y: frame.size.height + attaker2.size.height)
        attaker2.physicsBody = SKPhysicsBody(circleOfRadius: attaker2.size.width/2)
        
        attaker2.physicsBody?.categoryBitMask = balloonCategory
        attaker2.physicsBody?.contactTestBitMask = torpedoCategory
        attaker2.physicsBody?.collisionBitMask = 0
        
        addChild(attaker2)
        
        let animationDuration = difficultManager.getBalloonAnimationDurationInterval()
        
        var actionArray1 = [SKAction]()
        actionArray1.append(SKAction.move(to: CGPoint(x: position1, y: -attaker1.size.height), duration: animationDuration))
       
        actionArray1.append(SKAction.run(balloonGotBase))
        actionArray1.append(SKAction.removeFromParent())
        
        var actionArray2 = [SKAction]()
        actionArray2.append(SKAction.move(to: CGPoint(x: position2, y: -attaker2.size.height), duration: animationDuration))
        
        actionArray2.append(SKAction.run(balloonGotBase))
        actionArray2.append(SKAction.removeFromParent())
        
        attaker1.run(SKAction.sequence(actionArray1))
        attaker2.run(SKAction.sequence(actionArray2))
    }
    
    func balloonGotBase() {
        run(SKAction.playSoundFileNamed("looseLife.mp3", waitForCompletion: false))
        if livesArray.count > 0 {
            let lifeNode = livesArray.first
//            lifeNode?.removeFromParent()
//            livesArray.removeFirst()
        }
        if livesArray.count == 0 {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = SKScene(fileNamed: "GameOver") as! GameOver
            gameScene.score = self.score
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        fireTorpedo()
//    }
    
//    func fireTorpedo() {
//        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
//        torpedoNode.position = player.position
//        torpedoNode.position.y += 5
//        torpedoNode.size = CGSize(width: 30, height: 30)
//        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width/2)
//
//        torpedoNode.physicsBody?.categoryBitMask = torpedoCategory
//        torpedoNode.physicsBody?.contactTestBitMask = balloonCategory
//        torpedoNode.physicsBody?.collisionBitMask = 0
//        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
//
//        addChild(torpedoNode)
//
//        let animationDuration = 1.0
//
//        var actionArray = [SKAction]()
//        actionArray.append(torpedoSoundAction)
//        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: frame.size.height + torpedoNode.size.height), duration: animationDuration))
//        actionArray.append(SKAction.removeFromParent())
//        torpedoNode.run(SKAction.sequence(actionArray))
//    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var bodyWithMaxCategoryBitMask: SKPhysicsBody
        var bodyWithMinCategoryBitMask: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bodyWithMaxCategoryBitMask = contact.bodyA
            bodyWithMinCategoryBitMask = contact.bodyB
        } else {
            bodyWithMaxCategoryBitMask =  contact.bodyB
            bodyWithMinCategoryBitMask = contact.bodyA
        }
        let isTorpedoBody = (bodyWithMaxCategoryBitMask.categoryBitMask & torpedoCategory) != 0
        let isBalloonBody = (bodyWithMinCategoryBitMask.categoryBitMask & balloonCategory) != 0
        
        if  isTorpedoBody && isBalloonBody {
            guard let torpedoNode = bodyWithMaxCategoryBitMask.node else {return}
            guard let balonNode = bodyWithMinCategoryBitMask.node else {return}
            torpedoDidCollideWithBalloon(torpedoNode: torpedoNode as! SKSpriteNode, balloonNode: balonNode as! SKSpriteNode)
        }
        
    }
    
    func torpedoDidCollideWithBalloon(torpedoNode: SKSpriteNode, balloonNode: SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = balloonNode.position
        addChild(explosion)
        
        run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        torpedoNode.removeFromParent()
        balloonNode.removeFromParent()
        
        run(SKAction.wait(forDuration: 1)) {
            explosion.removeFromParent()
        }
        score += 5
    }
    
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        if player.position.x <= 20 {
            player.position.x = 20
        } else if player.position.x >= frame.size.width - 20 {
            player.position.x = frame.size.width - 20
        }
        
        // Loop through all children (balloon nodes) in the scene
        for node in children {
            if let balloonNode = node as? SKSpriteNode {
                if balloonNode.physicsBody?.categoryBitMask == balloonCategory {
                    // Check if the spaceship passed through the balloon
                    updateScore(playerNode: player, balloonNode: balloonNode)
                }
            }
        }
    }

}
