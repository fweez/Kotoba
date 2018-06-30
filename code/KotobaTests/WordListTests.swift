//
//  WordListTests.swift
//  Kotoba
//
//  Created by Will Hains on 2016-06-25.
//  Copyright © 2016 Will Hains. All rights reserved.
//

import XCTest
@testable import Kotoba

class WordListTests: XCTestCase
{
	func testRemoveShouldDoNothingWhenElementNotFound()
	{
		var subject: [String] = ["a", "b", "c"]
		subject.remove("d")
		XCTAssertEqual(subject, ["a", "b", "c"])
	}
	
	func testRemoveShouldRemoveOnlyFirstElementFound()
	{
		var subject: [String] = ["a", "b", "c", "b"]
		subject.remove("b")
		XCTAssertEqual(subject, ["a", "c", "b"])
	}
	
	func testShouldAddNonDuplicateToHead()
	{
		var subject: [String] = ["a", "b", "c"]
		subject.add(possibleDuplicate: "d")
		XCTAssertEqual(subject, ["d", "a", "b", "c"])
	}
	
	func testShouldMoveDuplicateToHead()
	{
		var subject: [String] = ["a", "b", "c"]
		subject.add(possibleDuplicate: "b")
		XCTAssertEqual(subject, ["b", "a", "c"])
	}
    
    func testShouldReplaceOldWordWithNew()
    {
        let distantPastDates = [Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 1), Date(timeIntervalSince1970: 2)]
        var words = ["a", "b", "c"].enumerated().map { Word(text: $1, time: distantPastDates[$0]) }
        let now = Date()
        words.add(possibleDuplicate: Word(text: "b", time: now))
        let first = words.first
        XCTAssertEqual(first?.text, "b")
        XCTAssertEqual(first?.time, now)
    }
}
