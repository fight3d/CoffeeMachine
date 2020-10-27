//
//  CoffeeMachine.swift
//  CoffeeMachine
//
//  Created by 3droot on 25.10.2020.
//

import Foundation
import AVFoundation

class CoffeeMachine {

    enum DrinkType: Int {
        case espresso, americano, cappuccino, latte, hotwater
        
        var name : String {
            switch self {
            case .espresso: return "Espresso"
            case .americano: return "Americano"
            case .cappuccino: return "Cappuccino"
            case .latte: return "Latte"
            case .hotwater: return "Hot water"
            }
        }
        //recipes
        var coffeeBeamsAmout: Double {
            switch self {
            case .espresso: return 30
            case .americano: return 25
            case .cappuccino: return 20
            case .latte: return 20
            case .hotwater: return 0
            }
        }
        var milkAmount: Double {
            switch self {
            case .espresso: return 0
            case .americano: return 0
            case .cappuccino: return 50
            case .latte: return 100
            case .hotwater: return 0
            }
        }
        var waterAmount: Double {
            switch self {
            case .espresso: return 50
            case .americano: return 100
            case .cappuccino: return 100
            case .latte: return 80
            case .hotwater: return 200
            }
        }
    }
    
    enum IngridientsType: Int {
        case water, milk, coffeeBeans
        
        var name : String {
            switch self {
            case .water: return "Water"
            case .milk: return "Milk"
            case .coffeeBeans: return "Coffee beans"
          
            }
        }
    }
    
    enum Sounds: String {
        case fillWater, fillBeans, clean, grind, fillCoffeeCup, groundsAppear
    }
    
    
    var groundsContainer: Int
    let groundsContainerCapacity = 4
    let coffeeBeansCapacity = 150.0
    let milkCapacity = 300.0
    let waterCapacity = 500.0
    var ingridientsStock: [IngridientsType: Double]
    
    var audioPlayer = AVAudioPlayer()
    
    init() {
        self.groundsContainer = 0
        self.ingridientsStock = [.coffeeBeans: 0, .milk : 0, .water : 0]
    }
    
    func fillIngridients(ingridients: IngridientsType) -> String {
        
        switch ingridients {
        case .coffeeBeans:
            ingridientsStock[.coffeeBeans] = coffeeBeansCapacity
        case .milk:
            ingridientsStock[.milk] = milkCapacity
        case .water:
            ingridientsStock[.water] = waterCapacity
        }
        return "\(ingridients.name) has filled"
    }
    
    func prepare(drink: DrinkType) -> (String, Bool) {
        guard !isGroundsContainerFull() else {return ("Can not make \(drink). Empty grounds container", false)}
        guard ingridientsStock[.coffeeBeans]! >= drink.coffeeBeamsAmout else { return ("Can not make \(drink). Fill cofffee beans", false)}
        guard ingridientsStock[.milk]! >= drink.milkAmount else { return ("Can not make \(drink). Fill milk", false)}
        guard ingridientsStock[.water]! >= drink.waterAmount else { return ("Can not make \(drink). Fill water", false)}
        
        //take ingridients from stock
        ingridientsStock[.coffeeBeans]! -= drink.coffeeBeamsAmout
        ingridientsStock[.milk]! -= drink.milkAmount
        ingridientsStock[.water]! -= drink.waterAmount
        
        if drink != .hotwater {
            groundsContainer += 1
        }
        
       
        return ("Your \(drink) is ready", true)
    }
    
    func isGroundsContainerFull() -> Bool {
        var status = false
        if groundsContainer >= groundsContainerCapacity {
            status = true
        }
        return status
    }
    
    func emptyGroundsContainer ()  {
        groundsContainer = 0
    }

    
    func playSound(soundName: Sounds){
        guard let path = Bundle.main.path(forResource: soundName.rawValue, ofType: "mp3") else {return}
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        }
        catch {
            print ("Sound Error")
        }
        audioPlayer.play()
    }
    
}
