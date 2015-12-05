//
//  ParserTests.swift
//  Feeder
//
//  Created by Tatsuya Tobioka on 11/23/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import Feeder

class ParserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

    func testFindWithAtom() {
        let filename = "test.atom"
        parse(filename) { entries, error in
            XCTAssertEqual(entries.count, 2)
            
            XCTAssertEqual(entries[0].title, "Atom-Powered Robots Run Amok")
            XCTAssertEqual(entries[0].href, "http://example.org/2003/12/13/atom03")
            XCTAssertEqual(entries[0].summary, "Some text.")
            
            XCTAssertEqual(entries[1].title, "Atom-Powered Robots Run Amok 2")
            XCTAssertEqual(entries[1].href, "http://example.org/2003/12/13/atom04")
            XCTAssertEqual(entries[1].summary, "Some content.")
        }
    }

    func testFindWithRSS() {
        let filename = "test.rss"
        parse(filename) { entries, error in
            XCTAssertEqual(entries.count, 4)
            
            XCTAssertEqual(entries[0].title, "Star City")
            XCTAssertEqual(entries[0].href, "http://liftoff.msfc.nasa.gov/news/2003/news-starcity.asp")
            XCTAssertEqual(entries[0].summary, "How do Americans get ready to work with Russians aboard the International Space Station? They take a crash course in culture, language and protocol at Russia's <a href=\"http://howe.iki.rssi.ru/GCTC/gctc_e.htm\">Star City</a>.")
            
            XCTAssertEqual(entries[1].title, "")
            XCTAssertEqual(entries[1].href, "")
            XCTAssertEqual(entries[1].summary, "Sky watchers in Europe, Asia, and parts of Alaska and Canada will experience a <a href=\"http://science.nasa.gov/headlines/y2003/30may_solareclipse.htm\">partial eclipse of the Sun</a> on Saturday, May 31st.")

            XCTAssertEqual(entries[2].title, "The Engine That Does More")
            XCTAssertEqual(entries[2].href, "http://liftoff.msfc.nasa.gov/news/2003/news-VASIMR.asp")
            XCTAssertEqual(entries[2].summary, "Before man travels to Mars, NASA hopes to design new engines that will let us fly through the Solar System more quickly.  The proposed VASIMR engine would do that.")

            XCTAssertEqual(entries[3].title, "Astronauts' Dirty Laundry")
            XCTAssertEqual(entries[3].href, "http://liftoff.msfc.nasa.gov/news/2003/news-laundry.asp")
            XCTAssertEqual(entries[3].summary, "Compared to earlier spacecraft, the International Space Station has many luxuries, but laundry facilities are not one of them.  Instead, astronauts have other options.")
        }
    }

    func testFindWithRDF() {
        let filename = "test.rdf"
        parse(filename) { entries, error in
            XCTAssertEqual(entries.count, 2)
            
            XCTAssertEqual(entries[0].title, "Processing Inclusions with XSLT")
            XCTAssertEqual(entries[0].href, "http://xml.com/pub/2000/08/09/xslt/xslt.html")
            XCTAssertEqual(entries[0].summary, "Processing document inclusions with general XML tools can be problematic. This article proposes a way of preserving inclusion information through SAX-based processing.")
            
            XCTAssertEqual(entries[1].title, "Putting RDF to Work")
            XCTAssertEqual(entries[1].href, "http://xml.com/pub/2000/08/09/rdfdb/index.html")
            XCTAssertEqual(entries[1].summary, "Tool and API support for the Resource Description Framework is slowly coming of age. Edd Dumbill takes a look at RDFDB, one of the most exciting new RDF toolkits.")
        }
    }

    private func parse(filename: String, callback: Feeder.ParserCallback) {
        let expectation = expectationWithDescription("")
        guard let path = NSBundle.mainBundle().pathForResource(filename, ofType: nil) else { return XCTFail() }
        guard let data = NSData(contentsOfFile: path) else { return XCTFail() }
        let urlString = "http://example.com/\(filename)"
        
        Feeder.shared.session = MockSession(data: data)
        
        Feeder.shared.parse(urlString) { entries, error in
            callback(entries, error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
