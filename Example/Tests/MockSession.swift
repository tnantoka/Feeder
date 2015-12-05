//
//  MockSession.swift
//  Feeder
//
//  Created by Tatsuya Tobioka on 11/23/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit

class MockSession: NSURLSession {
    
    let data: NSData
    
    init(data: NSData) {
        self.data = data
        super.init()
    }
    
    override func dataTaskWithURL(url: NSURL, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) -> NSURLSessionDataTask {
        return MockTask(data: data, completionHandler: completionHandler)
    }
}

class MockTask: NSURLSessionDataTask {

    let data: NSData
    let completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void
    
    init(data: NSData, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void) {
        self.data = data
        self.completionHandler = completionHandler
        super.init()
    }
    
    override func resume() {
        completionHandler(data, nil, nil)
    }
}