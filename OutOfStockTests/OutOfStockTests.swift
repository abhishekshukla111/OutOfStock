//
//  OutOfStockTests.swift
//  OutOfStockTests
//
//  Created by abhishek.b.shukla on 10/03/19.
//  Copyright © 2019 Abhishek Shukla. All rights reserved.
//

import XCTest
@testable import OutOfStock

class OutOfStockTests: XCTestCase {
    
   
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testOutofstock() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        ViewController().outofstock(year: "2014") { (outOfStockProducts) in
            if outOfStockProducts == nil{
                XCTFail()
            }
        }
        
    }
    
    func testAPICall(){
        
        let testExpectation = expectation(description: "Api Call")
        let forecastURLString = "http://myserver.com/api/forecast/2014/"
        
        ViewController().getAPIResponse(for: forecastURLString) { (data, error) in
            if error != nil{
                XCTFail()
            }
            
            testExpectation.fulfill()
        }
        waitForExpectations(timeout: 10, handler: nil)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
