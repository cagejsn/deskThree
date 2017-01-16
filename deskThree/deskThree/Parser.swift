//
//  Parser.swift
//  Mal-Swift
//
//  Created by test on 1/6/17.
//  MIT License
//

import Foundation


public class Parser {
    
    private var numChars = "0123456789."
    private var function: Array<Any>
    private var cursor: Int
    private var domain: [Float64]
    private var range:  [Float64]
    
    init(functionString: String) {
        self.function = Array(functionString.characters)
        self.cursor = 0
        self.domain = Array()
        self.range = Array()
        
    }
    
    //can be optimized later
    /* takes array of strings targArray, and makes a string combining elements
     from position start to position stop. Compares to string comparedTo. Returns
     true if comparison holds up.*/
    private func getTrig() -> String {
        if(cursor+3 < function.count){
            print("made it to first bool")
            
            var s: String = ""
            for i in self.cursor...self.cursor+2 {
                s.append(String(describing: self.function[i]))
            }
            print(s)
            if("sin" == s || "cos" == s || "tan" == s){
                print("operator type is", s)
                return s
            }
        }
        return ""
    }
    
    /* function[cursor] is currently pointing to string */
    private func isNum() -> Bool{
        return numChars.contains(String(describing: function[cursor]))
    }
    
    /* obtains value of number starting at function[cursor]. Returns array of len domain.count
      containing only this character */
    private func parserGetNum() -> [Float64]{
        
        var s: String = ""
        var c: Int = self.cursor
        while(numChars.contains(String(describing: self.function[c]))){
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
            
        }else if(getTrig() != ""){
            self.cursor += 4
            
        }else{
            self.cursor += 1
            
        }
        if(self.cursor == function.count){
            return
        }
        
        while(String(describing: function[cursor]) == " "){
            self.cursor += 1 
        }
    }
    
    /* parses and calcualtes numbers, x, parenthesis, trig functions */
    private func parserHighPriority() -> [Float64] {
        
        print("entering high priority")
        
        let indicator = String(describing: self.function[self.cursor])
        print(indicator)
        var resultList: [Float64] = Array()
        
        if(indicator == "x" || indicator == "X"){
            
            for x in self.domain{
                resultList.append(x)
            }
            parserIncrimentCursor()
            return resultList
        }
        if(indicator == "("){
            parserIncrimentCursor()
            resultList = parserExpression()
            if(String(describing: self.function[self.cursor]) != ")"){
                print("ERROR unmatched (")
            }
            parserIncrimentCursor()
            return resultList
        }
        if(isNum()){
            
            resultList = parserGetNum()

            parserIncrimentCursor()
            return resultList
        }
        let type: String = getTrig()
        print(type)
        if(type != ""){
            parserIncrimentCursor()
            resultList = parserExpression()
            if(String(describing: self.function[self.cursor]) != ")"){
                print("ERROR unmatched (")
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
            }
            
        }
        return resultList
    }
    
    /* parses and calculates with * */
    private func parserMedPriority() -> [Float64]{
        
        var highPrioLeft: [Float64] = parserHighPriority()
        
        while(self.cursor < function.count && String(describing: self.function[self.cursor]) == "*"){
            parserIncrimentCursor()
            var highPrioRight: [Float64] = parserHighPriority()
            for i in 0..<self.domain.count{
                
                highPrioLeft[i] *= highPrioRight[i]
            }
        }
        return highPrioLeft
    }
    
    /* parses and calcualtes with + */
    private func parserLowPriority() -> [Float64]{
        
        var medPrioLeft: [Float64] = parserMedPriority()
        
        while(self.cursor < function.count && String(describing: self.function[self.cursor]) == "+"){
            
            parserIncrimentCursor()
            var medPrioRight: [Float64] = parserMedPriority()
            for i in 0..<self.domain.count{
                
                medPrioLeft[i] += medPrioRight[i]
            }
        }
        return medPrioLeft
    }
    
    /* simplifies mathematical function. Calls itself recursively to solve sub-expressions */
    private func parserExpression() -> [Float64]{
        
        return parserLowPriority()
    }
    
    /* takes range via int start and int end. creates totalsteps entries in self.range 
       that corrospond to function output. */
    public func parserPlot(start: Float64, end: Float64, totalSteps: Int){

        parserGenDomain(start: start, end: end, steps: totalSteps)
        self.range = parserExpression()
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
    
    /* gives caller all x values */
    public func getX() -> [Float64]{
        return self.domain
    }
    
    /* gives caller all y values */
    public func getY() -> [Float64]{
        return self.range
    }
    
} 
