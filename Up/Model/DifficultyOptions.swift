//
//  DifficultyOptions.swift
//  Up
//
//  Created by Oey Darryl Valencio Wijaya on 29/07/23.
//

import Foundation

enum DifficultyOptions: String, CaseIterable {
    case Easy, Medium, Hard
    
    var description: String {
        switch self {
        case .Easy:
            return "Easy"
        case .Medium:
            return "Medium"
        case .Hard:
            return "Hard"
        }
    }
}
