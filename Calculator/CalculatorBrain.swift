//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Krzysztof Kostrzewa on 28.12.2016.
//  Copyright © 2016 Krzysztof Kostrzewa. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    var resultIsPending = false
    
    private var accumulator = 0.0
    
    var description = " "
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    func setOperand(operand: Double) {
        if !resultIsPending {
            clear()
        }
        accumulator = operand
        description += numberFormatter.string(from: NSNumber(value: Double(String(operand))!))!
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(.pi),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "×" : Operation.BinaryOperation({ $0 * $1}),
        "÷" : Operation.BinaryOperation({ $0 / $1}),
        "+" : Operation.BinaryOperation({ $0 + $1}),
        "-" : Operation.BinaryOperation({ $0 - $1}),
        "=" : Operation.Equals,
        "Ln" : Operation.UnaryOperation(log),
        "x^n" : Operation.BinaryOperation(pow),
        "C" : Operation.Clear
    ]
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case Clear
    }
    
    private var operationSymbol = "";
    
    func performOperation(symbol: String) {
        
        if let operation = operations[symbol] {
            
            switch operation {
            case .Constant(let value):
                accumulator = value
                description += symbol
            case .UnaryOperation(let function):
                if resultIsPending {
                    let accSize = String(accumulator).characters.count
                    let endIndex = description.index(description.endIndex, offsetBy: -accSize)
                    description = description.substring(to: endIndex)
                    
                    description += symbol + "(" + numberFormatter.string(from: NSNumber(value: Double(String(accumulator))!))! + ")"
                    resultIsPending = false
                } else {
                    description = symbol + "(" + description + ")"
                }
                accumulator = function(accumulator)
            case .BinaryOperation(let function):
                operationSymbol = symbol
                description += symbol
                pending = PendingBinaryOperationInfo(binaryFuncion: function, firstOperand: accumulator)
                resultIsPending = true
            case .Equals:
                executePendingBinaryOperation(symbol: operationSymbol)
            case .Clear:
                clear()
                
            }
        }
    }
    
    private var exception: Dictionary<String, String> = [
        "x^n" : "^"
    ]
    
    private func executePendingBinaryOperation(symbol: String) {
        var symbol = symbol
        if pending != nil {
            
            if exception[symbol] != nil {
                symbol = exception[symbol]!
            }
            
            //description += String(accumulator)
            
            accumulator = pending!.binaryFuncion(pending!.firstOperand, accumulator)
            pending = nil
            resultIsPending = false
            
        }
    }
    
    private func clear(){
        pending = nil
        accumulator = 0.0
        description = " "
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFuncion: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
