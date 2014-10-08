//
//  ZKDataTests.swift
//  ZKDataTests
//
//  Created by Alex Zielenski on 10/6/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

import UIKit
import XCTest
//import ZKData

class ZKDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testData() {
        // This is an example of a functional test case.
        var data        = NSMutableData()
        data.nextInt    = 1
        data.nextShort  = 2
        data.nextLong   = 3
        data.nextFloat  = 4.0
        data.nextDouble = 5.0
        data.setStringAtOffset("aString", offset: data.currentOffset)

        data.writeToFile("/Users/Alex/Desktop/testData", atomically: false)

        data >| 0

        XCTAssert(1 == data.nextInt, "nextInt")
        XCTAssert(2 == data.nextShort, "nextShort")
        XCTAssert(3 == data.nextLong, "nextLong")
        XCTAssert(4.0 == data.nextFloat, "nextFloat")
        XCTAssert(5.0 == data.nextDouble, "nextDouble")
        XCTAssertEqual("aString", data.stringAtOffset(data.currentOffset, encoding: NSUTF8StringEncoding, length: 7), "Strings")

    }

    func testOperators() {
        var data = NSMutableData()
        XCTAssertEqual(data.currentOffset, 0, "original offset")
        data +> 20
        XCTAssertEqual(data.currentOffset, 0, "maximum offset")
        data <- 20
        XCTAssertEqual(data.currentOffset, 0, "minimum offset")
        data.setStringAtOffset("AAAAAAAAAAAAAAAAAAAA", offset: 0)
        data >| data.length
        XCTAssertEqual(data.currentOffset, data.length, "offset set")
        data <- 10
        XCTAssertEqual(10, data.currentOffset, "offset minus")
        data +> 10
        XCTAssertEqual(20, data.currentOffset, "offset plus")
    }
    
}
