//
//  Feeder.swift
//  Pods
//
//  Created by Tatsuya Tobioka on 11/19/15.
//
//

import Foundation

public class Feeder {
    public static let shared = Feeder()
    
    public typealias FinderCallback = (Page, NSError?) -> Void
    public typealias ParserCallback = ([Entry], NSError?) -> Void
    
    public var session = NSURLSession.sharedSession()
    
    public func find(urlString: String, callback: FinderCallback) {
        let _ = Finder(urlString: urlString, callback: callback)
    }

    public func parse(urlString: String, callback: ParserCallback) {
        let _ = Parser(urlString: urlString, callback: callback)
    }

    public func parse(feed: Feed, callback: ParserCallback) {
        parse(feed.href, callback: callback)
    }
}
