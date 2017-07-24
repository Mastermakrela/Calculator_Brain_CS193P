//
//  ViewController.swift
//  Calculator
//
//  Created by Krzysztof Kostrzewa on 27.12.2016.
//  Copyright © 2016 Krzysztof Kostrzewa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet private weak var display: UILabel!
    @IBOutlet private weak var underDisplay: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var resultIsPending = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
        }
        userIsInTheMiddleOfTyping = true
        
    }
    
    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            let kek = numberFormatter.string(from: NSNumber(value: Double(String(newValue))!))
            display.text = kek
        }
    }
    
    private var descriptionDisplay: String {
        get {
            return underDisplay.text ?? " "
        }
        set {
            if newValue != " " {
                underDisplay.text = newValue + (resultIsPending ? "…" : "=")
            } else {
                underDisplay.text = newValue
            }
            
        }
    }
    
    @IBAction func touchDot() {
        display.text = !display.text!.contains(".") ?  display.text! + "." : display.text!
    }
    
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            
            brain.performOperation(symbol: mathematicalSymbol)
            
        }
        resultIsPending = brain.resultIsPending
        displayValue = brain.result
        descriptionDisplay = brain.description
        
    }
    
}

