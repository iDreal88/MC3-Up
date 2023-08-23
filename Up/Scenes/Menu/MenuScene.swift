//
//  MenuScene.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import SpriteKit
import AVFoundation

class MenuScene: SKScene {
    var weatherKitManager = WeatherKitManager()
    var locationManager = LocationManager()
    
    var starField : SKEmitterNode!
    
    var newGameButtonNode: SKSpriteNode!
    var difficultyButtonNode: SKSpriteNode!
    var difficultyLabelNode: SKLabelNode!
    var gameTitleLabelNode: SKSpriteNode!
    var appleWeatherLabelNode: SKSpriteNode!
    var tempLabelNode: SKLabelNode!
    var leaderboardButtonNode: SKSpriteNode!
    var backgroundMusicPlayer: AVAudioPlayer!
    
    let newGameButtonName = "newGameButton"
    //    let difficultyButtonName = "difficultyButton"
    let leaderboardButtonName = "leaderboardButton"
    
    let userDefaults = UserDefaults.standard
    
    //    override init(size: CGSize) {
    //        super.init(size: size)
    //        if locationManager.authorisationStatus == .authorizedWhenInUse{
    //            weatherKitManager.getWeather(latitude: locationManager.latitude, longitude: locationManager.longitude)
    //        }
    //    }
    //
    //    required init?(coder aDecoder: NSCoder) {
    //        fatalError("init(coder:) has not been implemented")
    //    }
    
    override func didMove(to view: SKView) {
        //        setupTempTitleLabel()
        setupPhisicsWord()
        setupGameTitleLabel()
        //        setupStartField()
        setupNewGameButtonNode()
        //        setupDifficultyButtonNode()
        //        setupDifficultLabelNode()
        setupLeaderboardButtonNode()
        setupMenuMusic()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == newGameButtonName {
            Task{
                do{
                    showLoadingScreen()
                    try await weatherKitManager.getWeather(latitude:locationManager.latitude, longitude:locationManager.longitude)
                    hideLoadingScreen()
                    print(weatherKitManager.weather?.currentWeather)
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    let gameScene = GameScene(size: self.size)
                    print(self.weatherKitManager.condition)
                    print(self.weatherKitManager.temp)
                    print(self.locationManager.latitude)
                    self.view?.presentScene(gameScene, transition: transition)
                }catch{
                    
                }
            }
        } else if nodesArray.first?.name == leaderboardButtonName {
            showingLeaderboard()
        } else{
            
        }
        
    }
    //    private func setupTempTitleLabel(){
    //        tempLabelNode = childNode(withName: "tempLabel") as? SKLabelNode
    //        let yPosition = gameTitleLabelNode.position.y
    //        gameTitleLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    //
    //    }
    //gameTitleLabel
    private func setupGameTitleLabel() {
        gameTitleLabelNode = self.childNode(withName: "gameTitleLabel") as? SKSpriteNode
        let yPosition = gameTitleLabelNode.position.y
        gameTitleLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    private func setupAppleWeatherLabel() {
        appleWeatherLabelNode = self.childNode(withName: "appleWeatherLabel") as? SKSpriteNode
        let yPosition = appleWeatherLabelNode.position.y
        appleWeatherLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    private func setupNewGameButtonNode() {
        newGameButtonNode = self.childNode(withName: newGameButtonName) as? SKSpriteNode
        let yPosition = newGameButtonNode.position.y
        newGameButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    func showLoadingScreen() {
        
        let loadingBackground = SKSpriteNode(color: .white, size: CGSize(width: frame.size.width, height: frame.size.height))
        loadingBackground.alpha = 0.7
        loadingBackground.position = CGPoint(x: frame.midX, y: frame.midY)
        loadingBackground.zPosition = 2
        addChild(loadingBackground)
        
        let spinner = SKSpriteNode(imageNamed: "spinner")
        
        spinner.position = CGPoint(x: frame.midX, y: frame.midY)
        let spinnerImageSize = CGSize(width: 100, height: 100)
        spinner.color = .white
        spinner.size = spinnerImageSize
        spinner.zPosition = 3
        
        addChild(spinner)
        let rotateAction = SKAction.rotate(byAngle: .pi, duration: 1)
        let repeatAction = SKAction.repeatForever(rotateAction)
        spinner.run(repeatAction)
        
    }
    
    func hideLoadingScreen() {
        for node in children {
            node.removeFromParent()
        }
    }
    
    func setupMenuMusic() {
        if let musicURL = Bundle.main.url(forResource: "menu_music", withExtension: "mp3") {
            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient)
                try AVAudioSession.sharedInstance().setActive(true)
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer.numberOfLoops = 0 // Set to -1 for looping
                backgroundMusicPlayer.play()
            } catch {
                print("Error loading music: \(error.localizedDescription)")
            }
        }
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
    
    //    private func setupStartField() {
    //        starField = self.childNode(withName: "starField") as? SKEmitterNode
    //        starField.advanceSimulationTime(10)
    //    }
    
    //    private func setupDifficultyButtonNode() {
    //        difficultyButtonNode = self.childNode(withName: difficultyButtonName) as? SKSpriteNode
    //        difficultyButtonNode.texture = SKTexture(imageNamed: difficultyButtonName)
    //        let yPosition = difficultyButtonNode.position.y
    //        difficultyButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    //    }
    
    //    private func setupDifficultLabelNode() {
    //        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as? SKLabelNode
    //        let yPosition = difficultyLabelNode.position.y
    //        difficultyLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    //        if let gameDifficulty = userDefaults.value(forKey: Constants.UserDefaultKeys.GameDifficulty) as? String {
    //            difficultyLabelNode.text = gameDifficulty
    //        } else {
    //            difficultyLabelNode.text = DifficultyOptions.Easy.description
    //        }
    //    }
    
    private func setupLeaderboardButtonNode() {
        leaderboardButtonNode = self.childNode(withName: leaderboardButtonName) as? SKSpriteNode
        leaderboardButtonNode.texture = SKTexture(imageNamed: "leaderboardLabel")
        let yPosition = leaderboardButtonNode.position.y
        leaderboardButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    //    func changeDifficulty() {
    //        guard let difficulty = DifficultyOptions(rawValue: difficultyLabelNode.text!) else { return }
    //        switch difficulty {
    //        case .Easy:
    //            difficultyLabelNode.text = DifficultyOptions.Medium.description
    //            userDefaults.set(DifficultyOptions.Medium.description, forKey: Constants.UserDefaultKeys.GameDifficulty)
    //        case .Medium:
    //            difficultyLabelNode.text = DifficultyOptions.Hard.description
    //            userDefaults.set(DifficultyOptions.Hard.description, forKey: Constants.UserDefaultKeys.GameDifficulty)
    //        case .Hard:
    //            difficultyLabelNode.text = DifficultyOptions.Easy.description
    //            userDefaults.set(DifficultyOptions.Easy.description, forKey: Constants.UserDefaultKeys.GameDifficulty)
    //        }
    //    }
    
    func showingLeaderboard(){
        GameCenterManager.shared.showLeaderboard()
    }
    
}

