//
//  GameViewController.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 28/07/23.
//

import UIKit
import SpriteKit
import GameplayKit
import Foundation
import GameKit

class GameViewController: UIViewController, GameCenterHelperDelegate {
    func didChangeAuthStatus(isAuthenticated: Bool) {
        <#code#>
    }
    
    func presentGameCenterAuth(viewController: UIViewController?) {
        <#code#>
    }
    
    private var gameKitHelper: GameKitHelper!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        gameKitHelper = GameKitHelper()
        gameKitHelper.delegate = self
        gameKitHelper.authenticatePlayer()
        if let view = self.view as! SKView?, let scene = MenuScene(fileNamed: "MenuScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
            //view.showsPhysics = true
        }
    }

}
