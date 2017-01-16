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
    
    func testParserPlotPoint(){
        
        let p: Parser = Parser(functionString: "x")
        p.parserPlot(start: 5.0, end: 5.0, totalSteps: 1)
        let v: Float64 = p.getY()[0]
        XCTAssert(v == 5.0)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
