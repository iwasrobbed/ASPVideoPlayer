//
//  ASPTestCase.swift
//  ASPVideoPlayer
//
//  Created by Rob Phillips on 4/14/17.
//  Copyright (c) 2017 Andrei-Sergiu Pitis. All rights reserved.
//

import XCTest

class ASPTestCase: XCTestCase {
    
    func asp_expectation(description: String) -> XCTestExpectation {
        let expectation = super.expectation(description: description)
        expectation.assertForOverFulfill = false
        return expectation
    }
    
    func asp_waitForExpectations(timeout: TimeInterval = 5) {
        waitForExpectations(timeout: timeout) { (error) in
            if let error = error {
                print(error)
            }
        }
    }
    
}
