//
//  GameScene.swift
//  coba UP
//
//  Created by Pravangasta Suihangya Balqis Wahyudi on 28/07/23.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene {
    

    let manager = CMMotionManager()
    override func didMove(to view: SKView) {
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){(data, error) in
            
            self.physicsWorld.gravity = CGVectorMake(CGFloat((data?.acceleration.x)!) * 10, 0)
        }
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
