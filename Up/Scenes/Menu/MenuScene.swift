//
//  MenuScene.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import SpriteKit



class MenuScene: SKScene {
    var weatherKitManager = WeatherKitManager()
    var locationManager = LocationManager()
    
    var starField : SKEmitterNode!
    
    var newGameButtonNode: SKSpriteNode!
    var difficultyButtonNode: SKSpriteNode!
    var difficultyLabelNode: SKLabelNode!
    var gameTitleLabelNode: SKLabelNode!
    var tempLabelNode: SKLabelNode!
    var leaderboardButtonNode: SKSpriteNode!
    
    let newGameButtonName = "newGameButton"
    let difficultyButtonName = "difficultyButton"
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
        setupGameTitleLabel()
        setupStartField()
        setupNewGameButtonNode()
        setupDifficultyButtonNode()
        setupDifficultLabelNode()
        setupLeaderboardButtonNode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let location = touch?.location(in: self) else { return }
        let nodesArray = self.nodes(at: location)
        if nodesArray.first?.name == newGameButtonName {
            Task{
                do{
                    try await weatherKitManager.getWeather(latitude:locationManager.latitude, longitude:locationManager.longitude)
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
        } else if nodesArray.first?.name == difficultyButtonName {
            changeDifficulty()
        } else{
            showingLeaderboard()
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
        gameTitleLabelNode = childNode(withName: "gameTitleLabel") as? SKLabelNode
        let yPosition = gameTitleLabelNode.position.y
        gameTitleLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    private func setupNewGameButtonNode() {
        newGameButtonNode = self.childNode(withName: newGameButtonName) as? SKSpriteNode
        let yPosition = newGameButtonNode.position.y
        newGameButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    private func setupStartField() {
        starField = self.childNode(withName: "starField") as? SKEmitterNode
        starField.advanceSimulationTime(10)
    }
    
    private func setupDifficultyButtonNode() {
        difficultyButtonNode = self.childNode(withName: difficultyButtonName) as? SKSpriteNode
        difficultyButtonNode.texture = SKTexture(imageNamed: difficultyButtonName)
        let yPosition = difficultyButtonNode.position.y
        difficultyButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    private func setupDifficultLabelNode() {
        difficultyLabelNode = self.childNode(withName: "difficultyLabel") as? SKLabelNode
        let yPosition = difficultyLabelNode.position.y
        difficultyLabelNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
        if let gameDifficulty = userDefaults.value(forKey: Constants.UserDefaultKeys.GameDifficulty) as? String {
            difficultyLabelNode.text = gameDifficulty
        } else {
            difficultyLabelNode.text = DifficultyOptions.Easy.description
        }
    }
    
    private func setupLeaderboardButtonNode() {
        leaderboardButtonNode = self.childNode(withName: leaderboardButtonName) as? SKSpriteNode
        leaderboardButtonNode.texture = SKTexture(imageNamed: difficultyButtonName)
        let yPosition = leaderboardButtonNode.position.y
        leaderboardButtonNode.position = CGPoint(x: frame.size.width/2, y: yPosition)
    }
    
    func changeDifficulty() {
        guard let difficulty = DifficultyOptions(rawValue: difficultyLabelNode.text!) else { return }
        switch difficulty {
        case .Easy:
            difficultyLabelNode.text = DifficultyOptions.Medium.description
            userDefaults.set(DifficultyOptions.Medium.description, forKey: Constants.UserDefaultKeys.GameDifficulty)
        case .Medium:
            difficultyLabelNode.text = DifficultyOptions.Hard.description
            userDefaults.set(DifficultyOptions.Hard.description, forKey: Constants.UserDefaultKeys.GameDifficulty)
        case .Hard:
            difficultyLabelNode.text = DifficultyOptions.Easy.description
            userDefaults.set(DifficultyOptions.Easy.description, forKey: Constants.UserDefaultKeys.GameDifficulty)
        }
    }
    
    func showingLeaderboard(){
        GameCenterManager.shared.showLeaderboard()
    }
    
}

