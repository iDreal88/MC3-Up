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
    var balloon: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let difficultManager = DifficultyManager()
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
//    let torpedoSoundAction: SKAction = SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false)
    var gameTimer: Timer!
    var spikes1 = ["left_spike"]
    var spikes2 = ["right_spike"]
    let spikeCategory: UInt32 = 0x1 << 1
    let torpedoCategory: UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    
    var livesArray: [SKSpriteNode]!
    
    let userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        setupLives()
        setupStarField()
        setupBalloon()
        setupPhisicsWord()
        setupScoreLabel()
        setupSpikes()
        setupCoreMotion()
    }
    
    func updateScore(balloonNode: SKSpriteNode, spikeNode: SKSpriteNode) {
         let balloonMaxY = balloonNode.position.y + balloonNode.size.height / 2
         let spikeMinY = spikeNode.position.y - spikeNode.size.height / 2
         
         if balloonMaxY > spikeMinY {
             score += 1 // Update the score when balloon passes through a spike
         }
     }
    
    func setupLives() {
        livesArray = [SKSpriteNode]()
        for life in 1...3 {
            let lifeNode = SKSpriteNode(imageNamed: "red_1")
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
    
    func setupBalloon() {
        balloon = SKSpriteNode(imageNamed: "red_1")
        balloon.size = CGSize(width: 80, height: 80)
        balloon.position = CGPoint(x: frame.size.width / 2, y: balloon.size.height / 2 + 20)
        addChild(balloon)
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
    
    func setupSpikes() {
        let timeInterval = difficultManager.getSpikeAparitionInterval()
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(addSpikes), userInfo: nil, repeats: true)
    }
    
    @objc func addSpikes() {
        //Shuffled array of spikes
        spikes1 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spikes1) as! [String]
        let spike1 = SKSpriteNode(imageNamed: spikes1[0])
        let spikePosition1 = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width)/2)
        let position1 = CGFloat(spikePosition1.nextInt())
        spike1.size = CGSize(width: 80, height: 60)
        spike1.position = CGPoint(x: position1, y: frame.size.height + spike1.size.height)
        spike1.physicsBody = SKPhysicsBody(circleOfRadius: spike1.size.width/2)
        
        spike1.physicsBody?.categoryBitMask = spikeCategory
        spike1.physicsBody?.contactTestBitMask = torpedoCategory
        spike1.physicsBody?.collisionBitMask = 0
        
        addChild(spike1)
        
        spikes2 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spikes2) as! [String]
        let spike2 = SKSpriteNode(imageNamed: spikes2[0])
        let spikePosition2 = GKRandomDistribution(lowestValue: Int(frame.size.width)/2, highestValue: Int(frame.size.width))
        let position2 = CGFloat(spikePosition2.nextInt())
        spike2.size = CGSize(width: 80, height: 60)
        spike2.position = CGPoint(x: position2, y: frame.size.height + spike2.size.height)
            spike2.physicsBody = SKPhysicsBody(circleOfRadius: spike2.size.width/2)
        
        spike2.physicsBody?.categoryBitMask = spikeCategory
        spike2.physicsBody?.contactTestBitMask = torpedoCategory
        spike2.physicsBody?.collisionBitMask = 0
        
        addChild(spike2)
        
        let animationDuration = difficultManager.getSpikeAnimationDurationInterval()
        
        var actionArray1 = [SKAction]()
        actionArray1.append(SKAction.move(to: CGPoint(x: position1, y: -spike1.size.height), duration: animationDuration))
       
        actionArray1.append(SKAction.run(spikeGotBase))
        actionArray1.append(SKAction.removeFromParent())
        
        var actionArray2 = [SKAction]()
        actionArray2.append(SKAction.move(to: CGPoint(x: position2, y: -spike2.size.height), duration: animationDuration))
        
        actionArray2.append(SKAction.run(spikeGotBase))
        actionArray2.append(SKAction.removeFromParent())
        
        spike1.run(SKAction.sequence(actionArray1))
        spike2.run(SKAction.sequence(actionArray2))
    }
    
    func spikeGotBase() {
//        run(SKAction.playSoundFileNamed("looseLife.mp3", waitForCompletion: false))
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
//    func didBegin(_ contact: SKPhysicsContact) {
//        var bodyWithMaxCategoryBitMask: SKPhysicsBody
//        var bodyWithMinCategoryBitMask: SKPhysicsBody
//
//        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
//            bodyWithMaxCategoryBitMask = contact.bodyA
//            bodyWithMinCategoryBitMask = contact.bodyB
//        } else {
//            bodyWithMaxCategoryBitMask =  contact.bodyB
//            bodyWithMinCategoryBitMask = contact.bodyA
//        }
//        let isTorpedoBody = (bodyWithMaxCategoryBitMask.categoryBitMask & torpedoCategory) != 0
//        let isSpikeBody = (bodyWithMinCategoryBitMask.categoryBitMask & spikeCategory) != 0
//
//        if  isTorpedoBody && isSpikeBody {
//            guard let torpedoNode = bodyWithMaxCategoryBitMask.node else {return}
//            guard let spikedNode = bodyWithMinCategoryBitMask.node else {return}
//            torpedoDidCollideWithSpike(torpedoNode: torpedoNode as! SKSpriteNode, spikeNode: spikedNode as! SKSpriteNode)
//        }
//
//    }
    
//    func torpedoDidCollideWithSpike(torpedoNode: SKSpriteNode, spikeNode: SKSpriteNode) {
//        let explosion = SKEmitterNode(fileNamed: "Explosion")!
//        explosion.position = spikeNode.position
//        addChild(explosion)
//
//        run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
//
//        torpedoNode.removeFromParent()
//        spikeNode.removeFromParent()
//
//        run(SKAction.wait(forDuration: 1)) {
//            explosion.removeFromParent()
//        }
//        score += 5
//    }
    
    override func didSimulatePhysics() {
        balloon.position.x += xAcceleration * 50
        if balloon.position.x <= 20 {
            balloon.position.x = 20
        } else if balloon.position.x >= frame.size.width - 20 {
            balloon.position.x = frame.size.width - 20
        }
        
        // Loop through all children (balloon nodes) in the scene
        for node in children {
            if let spikeNode = node as? SKSpriteNode {
                if spikeNode.physicsBody?.categoryBitMask == spikeCategory {
                    // Check if the spaceship passed through the balloon
                    updateScore(balloonNode: balloon, spikeNode: spikeNode)
                }
            }
        }
    }

}
