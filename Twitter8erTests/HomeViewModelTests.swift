//
//  HomeViewModelTests.swift
//  Twitter8er
//
//  Created by Josh Brown on 9/26/14.
//  Copyright (c) 2014 Roadfire Software. All rights reserved.
//

import XCTest

class HomeViewModelTests: XCTestCase {
    
    let viewModel = HomeViewModel()
    
    override func setUp() {
        super.setUp()
        viewModel.tweets = sampleTweets()
    }
    
    func testNumberOfSections() {
        XCTAssertEqual(1,  viewModel.numberOfSections())
    }
    
    func testNumberOfItemsInSection1() {
        XCTAssertEqual(2, viewModel.numberOfItemsInSection(1))
    }
    
    func testTweetForRowAtIndexPath_1_0() {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        XCTAssertEqual("I'm tweeting!", viewModel.tweetForRowAtIndexPath(indexPath))
    }
    
    func testUsernameForRowAtIndexPath_0_0() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        XCTAssertEqual("@jtbrown", viewModel.usernameForRowAtIndexPath(indexPath))
    }
    
    func testNameForRowAtIndexPath_1_0() {
        let indexPath = NSIndexPath(forRow: 1, inSection: 0)
        XCTAssertEqual("Zero Inbox", viewModel.nameForRowAtIndexPath(indexPath))
    }
    
    func sampleTweets() -> [NSDictionary] {
        return [
            ["text": "hello", "user":["screen_name": "jtbrown", "name": "Josh Brown"]],
            ["text": "I'm tweeting!", "user": ["screen_name": "zeroinboxapp", "name": "Zero Inbox"]]
        ]
    }
}
