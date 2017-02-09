//
//  Parser.swift
//  Mal-Swift
//
//  Created by test on 1/6/17.
//  MIT License
//

import Foundation

enum MathError: Error {
    case missingOperand
    case unmatchedParenthesis
    case unrecognizedCharacters
}

public class Parser {
    
    private var numChars = "0123456789."
    private var function: Array<Any>
    private var cursor: Int
    private var domain: [Float64]
    private var range:  [Float64]
    private var errorMSG = ""
    
    init(functionString: String) {
        self.function = Array(functionString.characters)
        self.cursor = 0
        self.domain = Array()
        self.range = Array()
        
    }
    
    //can be optimized later
    /* returns next word in function array if there is a recognized word present */
    private func getWord() -> String {
        
        var s: String = ""
        
        if(cursor+2 < function.count){//for keywords of length 2
            s.append(String(describing: function[cursor]))
            s.append(String(describing: function[cursor+1]))
            if("ln" == s){
                return s
            }
        }
        
        if(cursor+3 < function.count){
            s.append(String(describing: self.function[cursor+2]))
            if("sin" == s || "cos" == s || "tan" == s || "log" == s){
                print("operator type is", s)
                return s
            }
        }
        if(cursor+4 < function.count){
            s.append(String(describing: self.function[cursor+3]))
            if("sqrt" == s){
                return s
            }
        }
        if(cursor+6 < function.count){
            
            for i in self.cursor+4...self.cursor+5 {
                s.append(String(describing: self.function[i]))
            }
            if("arcsin" == s || "arccos" == s || "arctan" == s){
                print("operator type is", s)
                return s
            }
        }
        return ""
    }
    
    /* function[cursor] is currently pointing to string */
    private func isNum() -> Bool{
        return self.cursor < self.function.count && numChars.contains(String(describing: function[cursor]))
    }
    
    /* obtains value of number starting at function[cursor]. Returns array of len domain.count
      containing only this character */
    private func parserGetNum() -> [Float64]{
        
        var s: String = ""
        var c: Int = self.cursor
        while(c<self.function.count && numChars.contains(String(describing: self.function[c]))){
            s.append(String(describing: self.function[c]))
            c += 1
        }
        
        var returnArray: [Float64] = Array()
        let value: Float64 = Float64(s)!
        for _ in 0..<self.domain.count {
            returnArray.append(value)
        }
        return returnArray
    }
    
    /* increments cursor. increments by number length if is num. by 4 if is sin. by 1 otherwise */
    private func parserIncrimentCursor(){
        
        if isNum(){
            while(isNum()){
                self.cursor += 1
            }
            //can be optimized for sure
        }else if(getWord().characters.count == 2){
            self.cursor += 3
        }else if(getWord().characters.count == 3){
            self.cursor += 4
        }else if(getWord().characters.count == 4){
            self.cursor += 5
        }else if(getWord().characters.count == 6){
            self.cursor += 7
        }else{
            self.cursor += 1
            
        }
        if(self.cursor == function.count){
            return
        }
        
        while(self.cursor < function.count && String(describing: function[cursor]) == " "){
            self.cursor += 1 
        }
    }
    
    /* returns log base(val) */
    func logOf(base: Double, val: Double) -> Double {
        return log(val)/log(base)
    }
    
    func parserPower(baseList: [Float64]) throws -> [Float64]{
        
        if((self.cursor < self.function.count) && (String(describing: function[cursor]) == "^")){
            
            parserIncrimentCursor()

            if(String(describing: function[cursor]) == "("){
                parserIncrimentCursor()
                var powArray: [Float64]
                do {
                    try powArray = parserExpression()
                } catch let error {
                    throw error
                }
                for i in 0..<self.domain.count {
                    powArray[i] = pow(baseList[i], powArray[i])
                }
                if(String(describing: function[cursor]) != ")"){
                    throw MathError.unmatchedParenthesis
                }
                parserIncrimentCursor()
                return powArray
            }else
            {
                
                var powArray: [Float64]
                do {
                    try powArray = parserExpression()
                } catch let error {
                    throw error
                }
                for i in 0..<self.domain.count {
                    powArray[i] = pow(baseList[i], powArray[i])
                }
                return powArray
                
            }
            
        }
        return baseList
    }
    
    /* parses and calcualtes numbers, x, parenthesis, trig functions */
    private func parserHighPriority() throws -> [Float64] {
        
        print("entering high priority")
        if(self.cursor >= self.function.count){
            print("throw missingOperandError")
            throw MathError.missingOperand
        }
        let indicator = String(describing: self.function[self.cursor])
        print(indicator)
        var resultList: [Float64] = Array()
        
        if(indicator == "x" || indicator == "X"){
            
            for x in self.domain{
                resultList.append(x)
            }
            parserIncrimentCursor()
            do {
                try resultList = parserPower(baseList: resultList)

            } catch let error {
                throw error
            }
            return resultList
        }
        if(indicator == "("){
            parserIncrimentCursor()
            do {
                try resultList = parserExpression()

            } catch let error {
                throw error
            }
            if(self.cursor >= self.function.count || String(describing: self.function[self.cursor]) != ")"){
                throw MathError.unmatchedParenthesis
            }
            parserIncrimentCursor()
            
            do {
                try resultList = parserPower(baseList: resultList)
                
            } catch let error {
                throw error
            }
            return resultList
        }
        if(isNum()){
            
            resultList = parserGetNum()
            parserIncrimentCursor()
            do {
                try resultList = parserPower(baseList: resultList)
                
            } catch let error {
                throw error
            }
            
            return resultList
        }
        if(self.cursor < self.function.count && String(describing: function[cursor]) == "π"){
            parserIncrimentCursor()
            let value: Float64 = 3.141592653589793238462643383279502884197169399375105820974944592307816406286
            for _ in 0..<self.domain.count {
                resultList.append(value)
            }
            do {
                try resultList = parserPower(baseList: resultList)
                
            } catch let error {
                throw error
            }
            return resultList
        }
        if(self.cursor < self.function.count && String(describing: function[cursor]) == "e"){
            parserIncrimentCursor()
            let value: Float64 = 2.7182818284590452353602874713526624977572470936999595749
            for _ in 0..<self.domain.count {
                resultList.append(value)
            }
            do {
                try resultList = parserPower(baseList: resultList)
                
            } catch let error {
                throw error
            }
            return resultList
        }
        let type: String = getWord()
        if(type != ""){
            parserIncrimentCursor()
            do {
                try resultList = parserExpression()
                
            } catch let error {
                throw error
            }
            if(self.cursor >= self.function.count || String(describing: self.function[self.cursor]) != ")"){
                throw MathError.unmatchedParenthesis
            }
            parserIncrimentCursor()

            if(type == "sin"){
                for i in 0..<resultList.count {
                    resultList[i] = sin(resultList[i])
                }
            }else if(type == "cos"){
                for i in 0..<resultList.count {
                    resultList[i] = cos(resultList[i])
                }
            }else if(type == "tan"){
                for i in 0..<resultList.count {
                    resultList[i] = tan(resultList[i])
                }
            }else if(type == "arcsin"){
                for i in 0..<resultList.count {
                    resultList[i] = asin(resultList[i])
                }
            }else if(type == "arccos"){
                for i in 0..<resultList.count {
                    resultList[i] = acos(resultList[i])
                }
            }else if(type == "arctan"){
                for i in 0..<resultList.count {
                    resultList[i] = atan(resultList[i])
                }
            }else if(type == "sqrt"){
                for i in 0..<resultList.count {
                    resultList[i] = sqrt(resultList[i])
                }
            }else if(type == "log"){
                for i in 0..<resultList.count {
                    resultList[i] = logOf(base: 10, val: resultList[i])
                }
            }else if(type == "ln"){
                for i in 0..<resultList.count {
                    resultList[i] = logOf(base: 2.7182818284590452353602874713526624977572470936999595749, val: resultList[i])
                }
            }
            
        }
        do {
            try resultList = parserPower(baseList: resultList)
            
        } catch MathError.missingOperand {
            throw MathError.missingOperand
        }
        return resultList
    }
    
    /* parses and calculates with * */
    private func parserMedPriority() throws -> [Float64]{
        
        var highPrioLeft: [Float64]
        do {
            highPrioLeft = try parserHighPriority()
        } catch let error {
            throw error
        }
        
        if(self.cursor >= function.count){
            return highPrioLeft
        }
        
        print(self.cursor < function.count)
        
        var isMult: Bool = self.cursor < function.count && String(describing: self.function[self.cursor]) == "✕"
        var isDiv:  Bool = self.cursor < function.count && String(describing: self.function[self.cursor]) == "÷"
        
        while(self.cursor < function.count && (isMult || isDiv)){
            
            parserIncrimentCursor()
            var highPrioRight: [Float64]
            do {
                highPrioRight = try parserHighPriority()
            } catch let error {
                throw error
            }
            
            if(isMult){
                for i in 0..<self.domain.count{
                    highPrioLeft[i] *= highPrioRight[i]
                }
            }
            if(isDiv){
                for i in 0..<self.domain.count{
                    highPrioLeft[i] /= highPrioRight[i]
                }
            }
            isMult = self.cursor < function.count && String(describing: self.function[self.cursor]) == "✕"
            isDiv  = self.cursor < function.count && String(describing: self.function[self.cursor]) == "÷"
            
        }
        return highPrioLeft
    }
    
    /* parses and calcualtes with + */
    private func parserLowPriority() throws -> [Float64]{
        
        var medPrioLeft: [Float64]
        do {
            medPrioLeft = try parserMedPriority()
        } catch let error {
            throw error
        }
        
        if(self.cursor >= function.count){
            return medPrioLeft
        }
        var isPlus:  Bool = self.cursor < function.count && String(describing: self.function[self.cursor]) == "+"
        var isMinus: Bool = self.cursor < function.count && String(describing: self.function[self.cursor]) == "-"
        
        while(self.cursor < function.count && (isPlus || isMinus)){

            parserIncrimentCursor()
            
            var medPrioRight: [Float64]
            do {
                medPrioRight = try parserMedPriority()
            } catch let error {
                throw error
            }
            
            if(isPlus){
                for i in 0..<self.domain.count{
                    medPrioLeft[i] += medPrioRight[i]
                }
            }
            if(isMinus){
                for i in 0..<self.domain.count{
                    medPrioLeft[i] -= medPrioRight[i]
                }
            }
            isPlus  = self.cursor < function.count && String(describing: self.function[self.cursor]) == "+"
            isMinus = self.cursor < function.count && String(describing: self.function[self.cursor]) == "-"
        }
        
        return medPrioLeft
    }
    
    /* simplifies mathematical function. Calls itself recursively to solve sub-expressions */
    private func parserExpression() throws -> [Float64]{
        do {
            return try parserLowPriority()
        } catch MathError.missingOperand {
            throw MathError.missingOperand
        } catch let error {
            throw error
        }
    }
    
    /* takes range via int start and int end. creates totalsteps entries in self.range 
       that corrospond to function output. */
    public func parserPlot(start: Float64, end: Float64, totalSteps: Int) {

        self.errorMSG = ""
        self.cursor = 0
        
        self.parserGenDomain(start: start, end: end, steps: totalSteps)
        do {
            try self.range = self.parserExpression()
            
        } catch MathError.missingOperand {
            errorMSG = "Missing Operand"
        } catch MathError.unmatchedParenthesis {
            errorMSG = "Unmatched Parenthesis"
        } catch MathError.unrecognizedCharacters {
            errorMSG = "Unrecognized Operator Configuration"
        }catch let error {
            errorMSG = error.localizedDescription
        }
    }
    
    ///change function
    public func parserSetFunction(functionString: String){
        self.function = Array(functionString.characters)
    }
    
    /* generates array of x values for function given start end and number of steps */
    public func parserGenDomain(start: Float64, end: Float64, steps: Int){
        
        var domainArray: [Float64] = Array()
        let stepSize: Float64 = (end-start)/Float64(steps)
        var current: Float64 = start
        
        while(current<=end){
            domainArray.append(current)
            current+=stepSize
        }
        self.domain = domainArray
    }
    
    ///returns exception message if there is one
    public func getError() -> String{
        return self.errorMSG
    }
    
    /* gives caller all x values */
    public func getX() -> [Float64]{
        return self.domain
    }
    
    /* gives caller all y values */
    public func getY() -> [Float64]{
        return self.range
    }
    
} 
