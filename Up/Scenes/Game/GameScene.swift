//
//  GameScene.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import SpriteKit
import GameplayKit
import CoreMotion


    

struct PhysicsCatagory {
    static let None: UInt32 = 0
    static let Balloon : UInt32 = 10
    static let Spike : UInt32 = 20
    static let Space : UInt32 = 30
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    var weatherKitManager = WeatherKitManager()
    var locationManager = LocationManager()
    
    var starField: SKEmitterNode!
    var rainField: SKEmitterNode!
    var balloon: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    let difficultManager = DifficultyManager()
    var spikePair = SKSpriteNode()
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
//        if locationManager.authorisationStatus == .authorizedWhenInUse{
//            weatherKitManager.getWeather(latitude: locationManager.latitude, longitude: locationManager.longitude)
//        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func sceneDidLoad() {
//        if locationManager.authorisationStatus == .authorizedWhenInUse{
//            weatherKitManager.getWeather(latitude: locationManager.latitude, longitude: locationManager.longitude)
//        }
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
        physicsWorld.contactDelegate = self
        setupLives()
        setupStarField()
        setupBalloon()
        setupPhisicsWord()
        setupScoreLabel()
        setupSpikes()
        setupCoreMotion()
        
    }
    
    func updateScore() {
//            let balloonMaxY = balloon.position.y + balloon.size.height / 2
//            let spikeMinY = spikePair.position.y - spikePair.size.height / 2
//            if balloonMaxY > spikeMinY {
                score += 1 // Update the score when balloon passes through a spike
//            }
        }
    
    func setupLives() {
        livesArray = [SKSpriteNode]()
        for life in 1...1 {
            let lifeNode = SKSpriteNode(imageNamed: "red_1")
            lifeNode.size = CGSize(width: 44, height: 44)
            lifeNode.zPosition = 5
            lifeNode.position = CGPoint(x: self.frame.size.width - CGFloat(4 - life) * lifeNode.size.width, y: frame.size.height - 50)
            lifeNode.isHidden = true
            self.addChild(lifeNode)
            livesArray.append(lifeNode)
        }
    }
    
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.10 + self.xAcceleration * 0.50
            }
        }
    }
    
    func setupPhisicsWord() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        if (weatherKitManager.condition == "Heavy Rain" || weatherKitManager.condition == "Rain"){
            let background = SKSpriteNode(imageNamed: "Sunny")
            background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addChild(background)
            background.zPosition = -2
            background.alpha = 0.5
        }else if(weatherKitManager.condition == "Blizzard" || weatherKitManager.condition == "Blowing Snow" || weatherKitManager.condition == "Heavy Snow" || weatherKitManager.condition == "Freezing Rain" || weatherKitManager.condition == "Freezing Drizzle"){
            let background = SKSpriteNode(imageNamed: "Winter")
            background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addChild(background)
            background.zPosition = -2
            background.alpha = 1
        }else{
            let background = SKSpriteNode(imageNamed: "Sunny")
            background.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
            addChild(background)
            background.zPosition = -2
            background.alpha = 1
        }
        

    }
    
    func setupStarField() {
        Task{
            do{
                try await weatherKitManager.getWeather(latitude:locationManager.latitude, longitude:locationManager.longitude)
                print("Weather Game Scene: ",weatherKitManager.condition)
                if (weatherKitManager.condition == "Heavy Rain" || weatherKitManager.condition == "Rain"){
                    rainField = SKEmitterNode(fileNamed: "Rain")
                    rainField.position = CGPoint(x: 0, y: self.frame.maxY)
                    rainField.advanceSimulationTime(10)
                    addChild(rainField)
                    rainField.zPosition = -1
                }else if(weatherKitManager.condition == "Blizzard" || weatherKitManager.condition == "Blowing Snow" || weatherKitManager.condition == "Heavy Snow" || weatherKitManager.condition == "Freezing Rain" || weatherKitManager.condition == "Freezing Drizzle"){
                    starField = SKEmitterNode(fileNamed: "Snow")
                    starField.position = CGPoint(x: 0, y: self.frame.maxY)
                    starField.advanceSimulationTime(10)
                    addChild(starField)
                    starField.zPosition = -1
                }else{
                    
                }
            }catch{
                
            }
        }
        
        
    }
    
    func setupBalloon() {
        balloon = SKSpriteNode(imageNamed: "red_1")
        balloon.size = CGSize(width: 80, height: 80)
        balloon.position = CGPoint(x: frame.size.width / 2, y: balloon.size.height + 50 )
        addChild(balloon)
        balloon.name = "balloon"
        balloon.physicsBody = SKPhysicsBody(circleOfRadius: balloon.size.width/2.5)
        balloon.physicsBody?.categoryBitMask = PhysicsCatagory.Balloon
        balloon.physicsBody?.contactTestBitMask = PhysicsCatagory.Space
        balloon.physicsBody?.collisionBitMask = PhysicsCatagory.Spike
        balloon.physicsBody?.affectedByGravity = false
        
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
        //        spikes1 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spikes1) as! [String]
        //        let spike1 = SKSpriteNode(imageNamed: spikes1[0])
        //        let spikePosition1 = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width)/2 - Int(balloon.size.width))
        //        let position1 = CGFloat(spikePosition1.nextInt())
        //        spike1.size = CGSize(width: 80, height: 60)
        //        spike1.position = CGPoint(x: position1, y: frame.size.height + spike1.size.height)
        //        spike1.physicsBody = SKPhysicsBody(circleOfRadius: spike1.size.width/2)
        //
        //        spike1.physicsBody?.categoryBitMask = spikeCategory
        //        spike1.physicsBody?.contactTestBitMask = ballonCategory
        //        //        spike1.physicsBody?.collisionBitMask = 0
        //        spike1.name = "spike"
        //
        //        addChild(spike1)
        //
        //        spikes2 = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: spikes2) as! [String]
        //        let spike2 = SKSpriteNode(imageNamed: spikes2[0])
        //        let spikePosition2 = GKRandomDistribution(lowestValue: Int(frame.size.width)/2 + 20 , highestValue: Int(frame.size.width) )
        //        let position2 = CGFloat(spikePosition2.nextInt())
        //        spike2.size = CGSize(width: 80, height: 60)
        //        spike2.position = CGPoint(x: position2, y: frame.size.height + spike2.size.height)
        //        spike2.physicsBody = SKPhysicsBody(circleOfRadius: spike2.size.width/2)
        //
        //        spike2.physicsBody?.categoryBitMask = spikeCategory
        //        spike2.physicsBody?.contactTestBitMask = ballonCategory
        //        //        spike2.physicsBody?.collisionBitMask = 0
        //        spike2.name = "spike"
        //
        //        addChild(spike2)
        //        if spike2.position.x - spike1.position.x < balloon.size.width + 40  || spike2.position.x - spike1.position.x > (balloon.size.width + 20) * 2{
        //            print(spike2.position.x - spike1.position.x)
        //            repeat {
        //                let spikePosition1 = GKRandomDistribution(lowestValue: 0, highestValue: Int(frame.size.width)/2 - Int(balloon.size.width))
        //                let position1 = CGFloat(spikePosition1.nextInt())
        //                spike1.position = CGPoint(x: position1, y: frame.size.height + spike1.size.height)
        //
        //                let spikePosition2 = GKRandomDistribution(lowestValue: Int(frame.size.width)/2 , highestValue: Int(frame.size.width) )
        //                let position2 = CGFloat(spikePosition2.nextInt())
        //                spike2.position = CGPoint(x: position2, y: frame.size.height + spike2.size.height)
        //
        //            } while spike2.position.x - spike1.position.x < balloon.size.width + 20 || spike2.position.x - spike1.position.x > (balloon.size.width + 20) * 2
        //            print(spike2.position.x - spike1.position.x)
        //            let animationDuration = difficultManager.getSpikeAnimationDurationInterval()
        //            var actionArray1 = [SKAction]()
        //            actionArray1.append(SKAction.move(to: CGPoint(x: position1, y: -spike1.size.height), duration: animationDuration))
        //            actionArray1.append(SKAction.removeFromParent())
        //
        //            var actionArray2 = [SKAction]()
        //            actionArray2.append(SKAction.move(to: CGPoint(x: position2, y: -spike2.size.height), duration: animationDuration))
        //
        //
        //            actionArray2.append(SKAction.removeFromParent())
        //
        //            spike1.run(SKAction.sequence(actionArray1))
        //            spike2.run(SKAction.sequence(actionArray2))
        //
        //        }
        //        else{
        //            let animationDuration = difficultManager.getSpikeAnimationDurationInterval()
        //
        //            var actionArray1 = [SKAction]()
        //            actionArray1.append(SKAction.move(to: CGPoint(x: position1, y: -spike1.size.height), duration: animationDuration))
        //
        //
        //            actionArray1.append(SKAction.removeFromParent())
        //
        //            var actionArray2 = [SKAction]()
        //            actionArray2.append(SKAction.move(to: CGPoint(x: position2, y: -spike2.size.height), duration: animationDuration))
        //
        //
        //            actionArray2.append(SKAction.removeFromParent())
        //
        //            spike1.run(SKAction.sequence(actionArray1))
        //            spike2.run(SKAction.sequence(actionArray2))
        //        }
        //    }
        spikePair = SKSpriteNode()
        spikePair.name = "spikePair"
        spikePair.position = CGPoint(x: 0, y: self.frame.height)
        print("yyyyy", spikePair.position.y)
        
        let leftSpike = SKSpriteNode(imageNamed: "spike")
        let rightSpike = SKSpriteNode(imageNamed: "spike")
        let midSpace = SKSpriteNode(imageNamed: "space")
        leftSpike.position = CGPoint(x:  self.frame.width / 2 + 180, y: 0 )
        midSpace.position = CGPoint(x: self.frame.width / 2 , y:0  )
        rightSpike.position = CGPoint(x: self.frame.width / 2 - 180  , y: 0)
        print("leftspike", leftSpike.position.x)
        
        leftSpike.setScale(0.5)
        midSpace.setScale(0.5)
        rightSpike.setScale(0.5)
        rightSpike.size = CGSize(width: 250, height: 60)
        midSpace.size = CGSize(width: 100, height: 60)
        leftSpike.size = CGSize(width: 250, height: 60)
        
        leftSpike.physicsBody = SKPhysicsBody(rectangleOf: leftSpike.size)
        leftSpike.physicsBody?.categoryBitMask = PhysicsCatagory.Spike
        leftSpike.physicsBody?.collisionBitMask = PhysicsCatagory.Balloon
        leftSpike.physicsBody?.contactTestBitMask = PhysicsCatagory.Balloon
        leftSpike.physicsBody?.isDynamic = false
        leftSpike.physicsBody?.affectedByGravity = false
        
        //        midSpace.physicsBody = SKPhysicsBody(rectangleOf: midSpace.size)
        //        midSpace.physicsBody?.categoryBitMask = PhysicsCatagory.Space
        //        midSpace.physicsBody?.contactTestBitMask = PhysicsCatagory.Balloon
        //        midSpace.physicsBody?.isDynamic = false
        //        midSpace.physicsBody?.affectedByGravity = false
        //
        //        var coba = SKPhysicsBody(rectangleOf: midSpace.size)
        //        coba.categoryBitMask = PhysicsCatagory.Space
        //        coba.contactTestBitMask = PhysicsCatagory.Balloon
        ////        coba.collisionBitMask = PhysicsCatagory.None
        //        midSpace.physicsBody = coba
        midSpace.isHidden=true
        

        rightSpike.physicsBody = SKPhysicsBody(rectangleOf: rightSpike.size)
        rightSpike.physicsBody?.categoryBitMask = PhysicsCatagory.Spike
        rightSpike.physicsBody?.collisionBitMask = PhysicsCatagory.Balloon
        rightSpike.physicsBody?.contactTestBitMask = PhysicsCatagory.Balloon
        rightSpike.physicsBody?.isDynamic = false
        rightSpike.physicsBody?.affectedByGravity = false
        
        
        spikePair.addChild(leftSpike)
        spikePair.addChild(midSpace)
        spikePair.addChild(rightSpike)
        
        spikePair.zPosition = 1
        
        
        let randomPosition = difficultManager.getRandomNumber()
        spikePair.position.x = spikePair.position.x + randomPosition
        print("leftspike new", leftSpike.position.x)
        
        self.addChild(spikePair)
        let animationDuration = difficultManager.getSpikeAnimationDurationInterval()
        let distance = CGFloat(self.frame.height + spikePair.frame.height)
        let actionMove = SKAction.move(to: CGPoint(x: spikePair.position.x, y: -distance - 50), duration: animationDuration)
        let actionRemove = SKAction.removeFromParent()
        spikePair.run(SKAction.sequence([actionMove, actionRemove]))
        
        
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
    
    //    extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "balloon" {
            collisionBetween(ball: nodeA, object: nodeB)
        } else if nodeB.name == "balloon" {
            collisionBetween(ball: nodeB, object: nodeA)
        }
        if livesArray.count > 0 {
            let lifeNode = livesArray.first
            lifeNode?.removeFromParent()
            livesArray.removeFirst()
        }
        if livesArray.count == 0 {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = SKScene(fileNamed: "GameOver") as! GameOver
            gameScene.score = self.score
            self.view?.presentScene(gameScene, transition: transition)
        }
        
    }
    //
    func collisionBetween(ball: SKNode, object: SKNode) {
        if object.name == "spike" {
            //            if livesArray.count > 0 {
            //                let lifeNode = livesArray.first
            //                lifeNode?.removeFromParent()
            //                livesArray.removeFirst()
            //            }
            //            if livesArray.count == 0 {
            //                let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            //                let gameScene = SKScene(fileNamed: "GameOver") as! GameOver
            //                gameScene.score = self.score
            //                self.view?.presentScene(gameScene, transition: transition)
            //            }
        }
    }
    //
    override func didSimulatePhysics() {
        balloon.position.x += xAcceleration * 50
        
        var passedSpikes = Set<SKSpriteNode>()
        
        enumerateChildNodes(withName: "spikePair") { (spike, _) in
            if let spikeNode = spike as? SKSpriteNode {
                
//                print("Position Balon:", self.balloon.position)
//                print("Position Spike:", spikeNode.position)
                if abs(spikeNode.position.y)  > self.balloon.position.y && abs(spikeNode.position.y)  < self.balloon.position.y + 2 {
                    print("Pass find \(self.balloon.position.y) = \(spikeNode.position.y)")
                    // Balloon has passed the spike pair
//                    passedSpikes.insert(spikeNode)
                    self.updateScore()

//                    self.updateScore()
                }
            }
        }

        for passedSpike in passedSpikes {
//            print("pas")
//            updateScore()
//            passedSpike.removeFromParent()
        }
        
        if balloon.position.x <= 20 {
            balloon.position.x = 20
        } else if balloon.position.x >= frame.size.width - 20 {
            balloon.position.x = frame.size.width - 20
        }
    }

    
}
