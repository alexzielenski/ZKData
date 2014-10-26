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

enum Audience: String {
    case Public = "Public"
    case Friends = "Friends"
    case Private = "Private"
}

enum Day: Int {
    case Sunday = 0
    case Monday
    case Tuesday
    case Wednesday
    case Thursday
    case Friday
    case Saturday
}

class ZKDataTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func getUnixWeekday(unixTime: NSTimeInterval, today: Day) -> Day {
        let days = Int(unixTime / (60 * 60 * 24))
        let weekdays = Int(days % 7)
        let raw: Int = (7 + (today.rawValue - weekdays)) % 7

        return Day(rawValue: raw)!
    }

    func testDate() {
        for x in -100...100 {
            let nextDate = NSDate(timeIntervalSinceNow: NSTimeInterval(x * 24 * 60 * 60))
            let cal = NSCalendar.currentCalendar()
            let components = cal.component(.WeekdayCalendarUnit, fromDate: nextDate)
            let weekday = getUnixWeekday(nextDate.timeIntervalSince1970, today: Day(rawValue: components - 1)!)
            if (4 != weekday.rawValue) {
                println("fail")
            } else {
                println("pass")
            }
        }
    }

    func testData() {
        // This is an example of a functional test case.
        var data        = NSMutableData()
        data.nextInt    = 1
        data.nextShort  = 2
        data.nextLong   = 3
        data.nextFloat  = 4.0
        data.nextDouble = 5.0
        data.setStringAtOffset("aString", length: 7, offset: data.currentOffset)

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
        data.setStringAtOffset("AAAAAAAAAAAAAAAAAAAA", length: 20, offset: 0)
        data >| data.length
        XCTAssertEqual(data.currentOffset, data.length, "offset set")
        data <- 10
        XCTAssertEqual(10, data.currentOffset, "offset minus")
        data +> 10
        XCTAssertEqual(20, data.currentOffset, "offset plus")
    }
    
}
