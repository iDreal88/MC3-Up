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
    
    func getBalloonAparitionInterval() -> TimeInterval {
        switch difficulty {
        case .Easy:
            return 0.75
        case .Medium:
            return 0.50
        case .Hard:
            return 0.30
        }
    }
    
    func getBalloonAnimationDurationInterval() -> TimeInterval {
        switch difficulty {
        case .Easy:
            return 6
        case .Medium:
            return 4.50
        case .Hard:
            return 3
        }
    }
    
}
