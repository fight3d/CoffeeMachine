//
//  ViewController.swift
//  CoffeeMachine
//
//  Created by 3droot on 25.10.2020.
//

import UIKit


class ViewController: UIViewController {

    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var milkImageView: UIImageView!
    @IBOutlet weak var waterImageView: UIImageView!
    @IBOutlet weak var groundsImageView: UIImageView!
    @IBOutlet weak var cleanButton: UIButton!
    @IBOutlet weak var cupImageView: UIImageView!
    @IBOutlet weak var coffeImageView: UIImageView!
    @IBOutlet weak var filImageView: UIImageView!
    @IBOutlet weak var handleRotationView: UIView!
    @IBOutlet weak var cupWithCoffeeView: UIView!
    @IBOutlet weak var powerButton: UIImageView!
    
    @IBOutlet var beamsCollection: [UIImageView]!
    
    
    private let coffeeMachine = CoffeeMachine()
    
    let milkFullPosY = 526.0
    let milkEmptyPosY = 860.0
    let waterFullPosY = 479.0
    let waterEmptyPosY = 860.0
            
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
       //fill stock
        
    }

    @IBAction func prepareAction(_ sender: UIButton) {
        let tag = sender.tag
        guard let drink = CoffeeMachine.DrinkType(rawValue: tag) else { return}
        let prepareResult = coffeeMachine.prepare(drink: drink)
        
        if prepareResult.1 {
            self.view.isUserInteractionEnabled = false
            self.powerButton.image = #imageLiteral(resourceName: "PowerRed")
            self.statusLabel.text = "Preparing your \(drink.name)"
            cupWithCoffeeView.transform = CGAffineTransform(translationX: 600, y: 0)
            coffeImageView.alpha = 0
            cupImageView.alpha = 1
            if drink != .hotwater {
            coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.grind)
            }
            UIView.animate(withDuration: 0.8, animations: {
                self.cupWithCoffeeView.transform = CGAffineTransform(translationX: 0, y: 0)
            }, completion: {_ in
                UIView.animate(withDuration: 0.8, animations: {
                    self.handleRotationView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
                }, completion: {_ in
                    self.filImageView.isHidden = false
                    self.updateIngridientsViews()
                    self.coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.fillCoffeeCup)
                    UIView.animate(withDuration: 0.8, delay: 2.1, animations: {
                        self.handleRotationView.transform = CGAffineTransform(rotationAngle: 0)
                    }, completion: {_ in
                        self.filImageView.isHidden = true
                        self.coffeImageView.alpha = 1
                        UIView.animate(withDuration: 1, animations: {
                            self.statusLabel.text = prepareResult.0
                            self.cupWithCoffeeView.transform = CGAffineTransform(scaleX: 2, y: 2)
                        }, completion: {_ in
                            UIView.animate(withDuration: 0.5, animations: {
                                self.cupImageView.alpha = 0
                                self.coffeImageView.alpha = 0
                            }, completion: {_ in
                                if self.coffeeMachine.isGroundsContainerFull() {
                                    self.showGrounds()
                                } else {
                                    self.statusLabel.text = "Choose your drink"
                                    self.powerButton.image = #imageLiteral(resourceName: "PowerGreen")
                                }
                                self.view.isUserInteractionEnabled = true
                               
                            })
                        })
                    })
                })
            })
        } else {
            self.statusLabel.text = prepareResult.0
            self.view.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func fillStockAction(_ sender: UIButton) {
        let tag = sender.tag
        fillStock(tag: tag)
        
    }
    
    //updated ingrideints during fill action
    func fillStock (tag: Int){
        if let ingridient = CoffeeMachine.IngridientsType(rawValue: tag) {
            statusLabel.text = coffeeMachine.fillIngridients(ingridients: ingridient)
        }
        switch tag {
        case 0:
            UIView.animate(withDuration: 1, animations: {
                self.coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.fillWater)
                self.waterImageView.frame.origin.y = 479
            })
        case 1:
            UIView.animate(withDuration: 1, animations: {
                self.coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.fillWater)
                self.milkImageView.frame.origin.y = 526
            })
        case 2:
            coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.fillBeans)
            UIView.animate(withDuration: 0.15, animations: {
                self.beamsCollection[0].alpha = 1
            }, completion: {_ in
                UIView.animate(withDuration: 0.15, animations: {
                    self.beamsCollection[1].alpha = 1
                }, completion: {_ in
                    UIView.animate(withDuration: 0.15, animations: {
                        self.beamsCollection[2].alpha = 1
                    }, completion: {_ in
                        UIView.animate(withDuration: 0.15, animations: {
                            self.beamsCollection[3].alpha = 1
                        })
                    })
                })
            })
      
        default:
            print("UNEXPECTED BUTTON")
        }
    }

    //updated ingridients after prepare
    func updateIngridientsViews(){
        //update milk and water
        let milkPos = milkEmptyPosY - coffeeMachine.ingridientsStock[.milk]! / coffeeMachine.milkCapacity * (milkEmptyPosY - milkFullPosY)
        let waterPos = waterEmptyPosY - coffeeMachine.ingridientsStock[.water]! / coffeeMachine.waterCapacity * (waterEmptyPosY - waterFullPosY)
        UIView.animate(withDuration: 1, animations: {
            self.milkImageView.frame.origin.y = CGFloat(milkPos)
        })
        UIView.animate(withDuration: 1, animations: {
            self.waterImageView.frame.origin.y = CGFloat(waterPos)
        })
        //update coffee beans
        let threshold = coffeeMachine.coffeeBeansCapacity / Double(beamsCollection.count)
        for i in 0...3 {
            if coffeeMachine.ingridientsStock[.coffeeBeans]! < threshold * Double((i + 1)) {
                beamsCollection[i].alpha = 0
            }
        }
    }
    
    func showGrounds(){
        powerButton.image = #imageLiteral(resourceName: "PowerRed")
        UIView.animate(withDuration: 0.3, animations: {
            self.groundsImageView.alpha = 1
        })
        coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.groundsAppear)
        cleanButton.isEnabled = true
        statusLabel.text = "Empty grounds container"
    }
  
    @IBAction func cleanButtonAction(_ sender: UIButton) {
        coffeeMachine.emptyGroundsContainer()
        coffeeMachine.playSound(soundName: CoffeeMachine.Sounds.clean)
        UIView.animate(withDuration: 0.3, animations: {
            self.groundsImageView.alpha = 0
        })
        cleanButton.isEnabled = false
        statusLabel.text = "Choose you drink"
        powerButton.image = #imageLiteral(resourceName: "PowerGreen")
    }
}

