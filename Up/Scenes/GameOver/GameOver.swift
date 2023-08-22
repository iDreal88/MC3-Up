//
//  GameOver.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import SpriteKit

class GameOver: SKScene {
    
    var starField: SKEmitterNode!
    var weatherKitManager = WeatherKitManager()
    var locationManager = LocationManager()
    var scoreNumberLabel: SKLabelNode!
    var newGameButtonNode: SKSpriteNode!
    var menuButtonNode: SKSpriteNode!
    
    var score: Int = 0
    
    override func didMove(to view: SKView) {
        setupPhisicsWord()
        setupStarField()
        setupScoreNumberLabel()
        setupNewGameButton()
        setupMenuButtonNode()
        saveLeaderboard()
    }
    
    func setupPhisicsWord() {
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
//        physicsWorld.contactDelegate = self
        
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
                    starField = SKEmitterNode(fileNamed: "Rain")
                    starField.position = CGPoint(x: 0, y: self.frame.maxY)
                    starField.advanceSimulationTime(10)
                    addChild(starField)
                    starField.zPosition = -1
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
    
    func saveLeaderboard(){
        let leaderboardID = "com.ada.Up.Score"
        let scores = score
        GameCenterManager.shared.saveScoreToLeaderboard(leaderboardID: leaderboardID, score: scores)
    }
    
    func setupMenuButtonNode() {
        menuButtonNode = childNode(withName: "menuButton") as? SKSpriteNode
        menuButtonNode.texture = SKTexture(imageNamed: "homeButton")
    }
    
//    func setupStarField() {
//        starField = self.childNode(withName: "starField") as? SKEmitterNode
//        starField.advanceSimulationTime(10)
//    }
    
    func setupScoreNumberLabel() {
        scoreNumberLabel = self.childNode(withName: "scoreNumberLabel") as? SKLabelNode
        scoreNumberLabel.text = "\(score)"
    }
    
    func setupNewGameButton() {
        newGameButtonNode = self.childNode(withName: "newGameButton") as? SKSpriteNode
        newGameButtonNode.texture = SKTexture(imageNamed: "playAgainLabel")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        guard let location = touch?.location(in: self) else { return }
        let node = nodes(at: location)
        if node[0].name == "newGameButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameScene = GameScene(size: self.size)
            self.view?.presentScene(gameScene, transition: transition)
        } else  if node[0].name == "menuButton" {
            let transition = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = SKScene(fileNamed: "MenuScene")!
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
    
}

