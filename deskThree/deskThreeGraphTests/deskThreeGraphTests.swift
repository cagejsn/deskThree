//
//  deskThreeGraphTests.swift
//  deskThreeGraphTests
//
//  Created by test on 1/16/17.
//  Copyright © 2017 desk. All rights reserved.
//

import XCTest

class deskThreeGraphTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testShouldPass(){
        XCTAssert(true)
    }
    
    func testParserPlotDiv(){
        
        let p: Parser = Parser(functionString: "6÷2")
        p.parserPlot(start: 5.0, end: 5.1, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        print(v)
        XCTAssert(v == 3.0)
    }
    func testParserPlotPoint(){
        
        let p: Parser = Parser(functionString: "6÷2-1")
        p.parserPlot(start: 5.0, end: 5.1, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        print(v)
        XCTAssert(v == 2.0)
    }
    func testParserPlotMultDiv(){
        
        let p: Parser = Parser(functionString: "6✕2÷3")
        p.parserPlot(start: 5.0, end: 5.1, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        print(v)
        XCTAssert(v == 4.0)
    }
    func testParserPlotPlusSub(){
        
        let p: Parser = Parser(functionString: "6+2-3")
        p.parserPlot(start: 5.0, end: 5.1, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        print(v)
        XCTAssert(v == 5.0)
    }
    func testParserPlotSubPlus(){
        
        let p: Parser = Parser(functionString: "6-2+3")
        p.parserPlot(start: 5.0, end: 5.1, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        print(v)
        XCTAssert(v == 7.0)
    }
    func testParserPlotSubMult(){
        
        let p: Parser = Parser(functionString: "6-2✕3")
        p.parserPlot(start: 5.0, end: 5.1, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        print(v)
        XCTAssert(v == 0.0)
    }
    
//    func testParserLinearFirstPoint(){
//        
//        let p: Parser = Parser(functionString: "x")
//        p.parserPlot(start: 5.0, end: 10, totalSteps: 100)
//        let v: Float64 = p.getY()[0]
//        XCTAssert(v == 5.0)
//    }
    
    func testSinOfExpression(){
        
        let p: Parser = Parser(functionString: "sin((2+1.1415926)÷2)")
        p.parserPlot(start: 5.0, end: 10, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        XCTAssert(v <= 1.0 && v >= 0.999)
    }
    
    func testParserRoot(){
        
        let p: Parser = Parser(functionString: "√(4)")
        p.parserPlot(start: 5.0, end: 10, totalSteps: 100)
        let v: Float64 = p.getY()[0]
        XCTAssert(v == 2.0)
    }
    func testParserSquare(){
        let p: Parser = Parser(functionString: "5^2")
        p.parserPlot(start: 5.0, end: 10, totalSteps: 100)
        let v: Float64 = p.getY()[0]
        XCTAssert(v == 25.0)
    }
    
    func testParserCoef(){
        let p: Parser = Parser(functionString: "5(5)")
        p.parserPlot(start: 5.0, end: 10, totalSteps: 100)
        let v: Float64 = p.getY()[0]
        XCTAssert(v == 25.0)
    }
    
    func testParserRootCoef(){
        let p: Parser = Parser(functionString: "5√(4)")
        p.parserPlot(start: 5.0, end: 10, totalSteps: 100)
        let v: Float64 = p.getY()[0]
        XCTAssert(v == 10.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
