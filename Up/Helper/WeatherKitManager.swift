//
//  WeatherKitManager.swift
//  Up
//
//  Created by David Christian on 14/08/23.
//

import Foundation
import WeatherKit

@MainActor class WeatherKitManager{
    var weather: Weather?
    
    func getWeather(latitude: Double, longitude: Double)async throws{
        
        
        do{
            print(latitude)
            print(longitude)
            let fetchedWeather = try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
            weather = fetchedWeather
            //                let fetchedWeather = try await Task.detached(priority: .userInitiated){
            //                    return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
            //                }.value
        } catch{
            fatalError("\(error)")
        }
        
    }
    //
    //
    //    func haha(latitude: Double, longitude: Double,completion:@escaping(Weather)->()) async{
    //        do{
    //            WeatherService().
    //
    //            try WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude)))
    //
    //            weather = try await Task.detached(priority: .userInitiated){
    //                return try await WeatherService.shared.weather(for: .init(latitude: latitude, longitude: longitude))
    //            }.value
    //        } catch{
    //            fatalError("\(error)")
    //        }
    //    }
    
    //    func getWeatherCondition(){
    //        async{
    //            do{
    //                weather = try await Task.detached(priority: .userInitiated){
    //                    return try await String(weather?.currentWeather.condition.description ?? "none")
    //                }.value
    //            }catch{
    //                fatalError("\(error)")
    //            }
    //        }
    //
    //    }
    
    var symbol: String{
        weather?.currentWeather.symbolName ?? "xmark"
    }
    
    var temp: String{
        let temp = weather?.currentWeather.temperature
        let convertedTemp = temp?.converted(to: .celsius).description
        return convertedTemp ?? "Connecting to Apple Weather Service"
    }
    
    var condition: String{
        weather?.currentWeather.condition.description ?? "None"
    }
}
