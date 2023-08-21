//
//  GameViewController.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 28/07/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var weatherKitManager = WeatherKitManager()
    var locationManager = LocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
//        if locationManager.authorisationStatus == .authorizedWhenInUse{
//            weatherKitManager.getWeather(latitude: locationManager.latitude, longitude: locationManager.longitude)
//            print(weatherKitManager.condition)
//        }
        print(weatherKitManager.condition)
        if let view = self.view as! SKView?, let scene = MenuScene(fileNamed: "MenuScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
//            view.showsFPS = true
//            view.showsNodeCount = true
            view.showsPhysics = true
        }
    }
    
}
