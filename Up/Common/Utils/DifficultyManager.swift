//
//  DifficultyManager.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import Foundation

class DifficultyManager {
    
    var difficulty: DifficultyOptions {
        if let difficulty = UserDefaults.standard.value(forKey: Constants.UserDefaultKeys.GameDifficulty) as? String, let difficultyOption = DifficultyOptions(rawValue: difficulty) {
            return difficultyOption
        } else {
            return .Easy
        }
    }
    
    func getSpikeAparitionInterval() -> TimeInterval {
        switch difficulty {
        case .Easy:
            return 1.50
        case .Medium:
            return 1.50
        case .Hard:
            return 1.00
        }
    }
    
    func getSpikeAnimationDurationInterval() -> TimeInterval {
        switch difficulty {
        case .Easy:
            return 8
        case .Medium:
            return 7
        case .Hard:
            return 6
        }
    }
    
    func getRandomNumber() -> CGFloat {
        switch difficulty {
        case .Easy:
            return CGFloat.random(min: -35, max: 35)
        case .Medium:
            return CGFloat.random(min: -65, max: 65)
        case .Hard:
            return CGFloat.random(min: -95, max: 95)
        }
    }
    
}
