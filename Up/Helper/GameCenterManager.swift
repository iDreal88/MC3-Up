//
//  GameCenterManager.swift
//  Up
//
//  Created by David Christian on 16/08/23.
//
import Foundation
import GameKit
import UIKit

class GameCenterManager: NSObject {
    
//    extension GameCenterManager:
//        GKGameCenterControllerDelegate {
//
//        func gameCenterViewControllerDidFinish(_gameCenterViewController:
//                                               GKGameCenterViewController) {
//            gameCenterViewController.dismiss (animated:
//                                                true, completion: nil)}
//    }
    
    //    @ObservedObject var playerModel = PlayerModel.shared
    //    @StateObject private var pointsCountManager: PointsCountManager
    //
    //    let LEADERBOARD_ID_SCORE = "score"
    //
    //    override init() {
    //        let pointsCountManager = PointsCountManager(context: PersistenceController.shared.container.viewContext)
    //        _pointsCountManager = StateObject(wrappedValue: pointsCountManager)
    //
    //        super.init()
    //
    //        authenticateUser { [self] success in
    //            if success {
    //                self.reportScore(score: pointsCountManager.pointsCount)
    //            }
    //        }
    //    }
    //
    //    func authenticateUser(completion: @escaping (Bool) -> Void) {
    //        playerModel.localPlayer.authenticateHandler = { [self] _, error in
    //            guard error == nil else {
    //                print(error?.localizedDescription ?? "")
    //                completion(false)
    //                return
    //            }
    //
    //            // Turn off Game Kit Active Indicator
    //            GKAccessPoint.shared.isActive = false
    //
    //            if playerModel.localPlayer.isAuthenticated {
    //                playerModel.localPlayer.register(self)
    //                completion(true)
    //            }
    //        }
    //    }
    //
    //    func reportScore(score: Int) {
    //        if playerModel.localPlayer.isAuthenticated {
    //            GKLeaderboard.submitScore(
    //                score,
    //                context: 0,
    //                player: playerModel.localPlayer,
    //                leaderboardIDs: [LEADERBOARD_ID_SCORE]
    //            ) { error in
    //                print("Leaderboard Submit Score Error:")
    //                if let errorText = error?.localizedDescription {
    //                    print(errorText)
    //                }
    //            }
    //            print("Score submitted: \(score)")
    //        }
    //    }
    static let shared = GameCenterManager()
        
        override init() {
            super.init()
        }
        
        func authenticatePlayer(completion: @escaping (Bool, Error?) -> Void) {
            let player = GKLocalPlayer.local
            
            player.authenticateHandler = { vc, error in
                if let error = error {
                    completion(false, error)
                    return
                }
                
                if player.isAuthenticated {
                    completion(true, nil)
                } else if let vc = vc {
                    // Present authentication view controller if needed
                    self.present(viewController: vc)
                }
            }
        }
        
        func showLeaderboard() {
            let leaderboardVC = GKGameCenterViewController()
            leaderboardVC.gameCenterDelegate = self
            leaderboardVC.viewState = .leaderboards
            present(viewController: leaderboardVC)
        }
        
        func saveScoreToLeaderboard(leaderboardID: String, score: Int) {
            let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
            scoreReporter.value = Int64(score)
            
            GKScore.report([scoreReporter]) { error in
                if let error = error {
                    print("Failed to save score: \(error.localizedDescription)")
                } else {
                    print("Score saved to leaderboard.")
                }
            }
        }
        
        private func present(viewController: UIViewController) {
            DispatchQueue.main.async {
                let topViewController = UIApplication.shared.windows.first?.rootViewController
                topViewController?.present(viewController, animated: true, completion: nil)
            }
        }
    }

    extension GameCenterManager: GKGameCenterControllerDelegate {
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true, completion: nil)
        }
    }
