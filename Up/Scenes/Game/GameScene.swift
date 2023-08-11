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
    let spikeCategory: UInt32 = 1
    let ballonCategory: UInt32 = 2
    let motionManager = CMMotionManager()
    var xAcceleration: CGFloat = 0
    var livesArray: [SKSpriteNode]!
    let userDefaults = UserDefaults.standard
    
    override func didMove(to view: SKView) {
        //        physicsWorld.contactDelegate = self
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
        balloon.name = "balloon"
        balloon.physicsBody = SKPhysicsBody(circleOfRadius: balloon.size.width/2.5)
        balloon.physicsBody?.categoryBitMask = ballonCategory
        balloon.physicsBody?.contactTestBitMask = spikeCategory
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
        let spikePosition1 = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width)/2 - Int(balloon.size.width))
        let position1 = CGFloat(spikePosition1.nextInt())
        spike1.size = CGSize(width: 80, height: 60)
        spike1.position = CGPoint(x: position1, y: frame.size.height + spike1.size.height)
        spike1.physicsBody = SKPhysicsBody(circleOfRadius: spike1.size.width/2)
        
        spike1.physicsBody?.categoryBitMask = spikeCategory
        spike1.physicsBody?.contactTestBitMask = ballonCategory
        //        spike1.physicsBody?.collisionBitMask = 0
        spike1.name = "spike"
        
        addChild(spike1)
        
        spikes2 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spikes2) as! [String]
        let spike2 = SKSpriteNode(imageNamed: spikes2[0])
        let spikePosition2 = GKRandomDistribution(lowestValue: Int(frame.size.width)/2 + 20 , highestValue: Int(frame.size.width) )
        let position2 = CGFloat(spikePosition2.nextInt())
        spike2.size = CGSize(width: 80, height: 60)
        spike2.position = CGPoint(x: position2, y: frame.size.height + spike2.size.height)
        spike2.physicsBody = SKPhysicsBody(circleOfRadius: spike2.size.width/2)
        
        spike2.physicsBody?.categoryBitMask = spikeCategory
        spike2.physicsBody?.contactTestBitMask = ballonCategory
        //        spike2.physicsBody?.collisionBitMask = 0
        spike2.name = "spike"
        
        addChild(spike2)
        if spike2.position.x - spike1.position.x < balloon.size.width + 40  || spike2.position.x - spike1.position.x > (balloon.size.width + 20) * 2{
            print(spike2.position.x - spike1.position.x)
            repeat {
                let spikePosition1 = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width)/2 - Int(balloon.size.width))
                let position1 = CGFloat(spikePosition1.nextInt())
                spike1.position = CGPoint(x: position1, y: frame.size.height + spike1.size.height)
                
                let spikePosition2 = GKRandomDistribution(lowestValue: Int(frame.size.width)/2 , highestValue: Int(frame.size.width) )
                let position2 = CGFloat(spikePosition2.nextInt())
                spike2.position = CGPoint(x: position2, y: frame.size.height + spike2.size.height)
                
            } while spike2.position.x - spike1.position.x < balloon.size.width + 20 || spike2.position.x - spike1.position.x > (balloon.size.width + 20) * 2
            print(spike2.position.x - spike1.position.x)
            let animationDuration = difficultManager.getSpikeAnimationDurationInterval()
            var actionArray1 = [SKAction]()
            actionArray1.append(SKAction.move(to: CGPoint(x: position1, y: -spike1.size.height), duration: animationDuration))
            actionArray1.append(SKAction.removeFromParent())
            
            var actionArray2 = [SKAction]()
            actionArray2.append(SKAction.move(to: CGPoint(x: position2, y: -spike2.size.height), duration: animationDuration))
            
            
            actionArray2.append(SKAction.removeFromParent())
            
            spike1.run(SKAction.sequence(actionArray1))
            spike2.run(SKAction.sequence(actionArray2))
            
        }
        else{
            let animationDuration = difficultManager.getSpikeAnimationDurationInterval()
            
            var actionArray1 = [SKAction]()
            actionArray1.append(SKAction.move(to: CGPoint(x: position1, y: -spike1.size.height), duration: animationDuration))
            
            
            actionArray1.append(SKAction.removeFromParent())
            
            var actionArray2 = [SKAction]()
            actionArray2.append(SKAction.move(to: CGPoint(x: position2, y: -spike2.size.height), duration: animationDuration))
            
            
            actionArray2.append(SKAction.removeFromParent())
            
            spike1.run(SKAction.sequence(actionArray1))
            spike2.run(SKAction.sequence(actionArray2))
        }
    }
    
    //    func spikeGotBase() {
    ////        run(SKAction.playSoundFileNamed("looseLife.mp3", waitForCompletion: false))
    //        if livesArray.count > 0 {
    //            let lifeNode = livesArray.first
    //            lifeNode?.removeFromParent()
    //            livesArray.removeFirst()
    //        }
    //        if livesArray.count == 0 {
    //            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
    //            let gameScene = SKScene(fileNamed: "GameOver") as! GameOver
    //            gameScene.score = self.score
    //            self.view?.presentScene(gameScene, transition: transition)
    //        }
    //    }
    //
    //    override func update(_ currentTime: TimeInterval) {
    //        // Called before each frame is rendered
    //    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "balloon" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "balloon" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
    }
    
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "spike" {
            if livesArray.count > 0 {
                let lifeNode = livesArray.first
//                lifeNode?.removeFromParent()
//                livesArray.removeFirst()
            }
            if livesArray.count == 0 {
                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameScene = SKScene(fileNamed: "GameOver") as! GameOver
                gameScene.score = self.score
                self.view?.presentScene(gameScene, transition: transition)
            }
        }
    }
    
    override func didSimulatePhysics() {
        balloon.position.x += xAcceleration * 50
        
        enumerateChildNodes(withName: "spike") { (spike, _) in
                if let spikeNode = spike as? SKSpriteNode {
                    if spikeNode.position.y + spikeNode.size.height / 2 < self.balloon.position.y - self.balloon.size.height / 2 {
                        // Balloon has passed the spike
                        self.updateScore(balloonNode: self.balloon, spikeNode: spikeNode)
                    }
                }
            }
        
        if balloon.position.x <= 20 {
            balloon.position.x = 20
        } else if balloon.position.x >= frame.size.width - 20 {
            balloon.position.x = frame.size.width - 20
        }
    }
}
