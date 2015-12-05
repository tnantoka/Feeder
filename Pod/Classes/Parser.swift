//
//  Parser.swift
//  Pods
//
//  Created by Tatsuya Tobioka on 11/19/15.
//
//

import Foundation

class Parser: NSObject, NSXMLParserDelegate {

    let url: NSURL
    let callback: Feeder.ParserCallback
    
    var parser: NSXMLParser!
    
    var entries = [Entry]()
    var format: Format?
    var elementName: String?
    
    var entry: Entry?
    
    init(urlString: String, callback: Feeder.ParserCallback) {
        url = NSURL(string: urlString)!
        self.callback = callback
        super.init()
        
        let task = Feeder.shared.session.dataTaskWithURL(url) { data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let data = data {
                    self.parser = NSXMLParser(data: data)
                    self.parser.delegate = self
                    self.parser.parse()
                } else {
                    self.callback([Entry](), error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch (format, elementName) {
        case (_, "feed"):
            format = .Atom
        case (_, "rss"):
            format = .RSS
        case (_, "rdf:RDF"):
            format = .RDF
        case (.Atom?, "entry"), (.RSS?, "item"), (.RDF?, "item"):
            entry = Entry()
        case (.Atom?, "link"):
            entry?.href = attributeDict["href"] ?? ""
        case (.Atom?, "content"):
            entry?.summary = ""
            self.elementName = elementName
        case (.Atom?, "summary"):
            if let summary = entry?.summary where summary.isEmpty {
                self.elementName = elementName
            }
        default:
            self.elementName = elementName
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        switch (format, elementName) {
        case (_, "title"?):
            entry?.title += string
        case (.RSS?, "link"?), (.RDF?, "link"?):
            entry?.href += string
        case (.Atom?, "content"?), (.Atom?, "summary"?), (.RSS?, "description"?), (.RDF?, "description"?):
            entry?.summary += string
       default:
            break
        }
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        callback(entries, nil)
    }
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        //print(parseError.localizedDescription)
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.elementName = nil
        guard let entry = entry else { return }
        switch (format, elementName) {
        case (.Atom?, "entry"), (.RSS?, "item"), (.RDF?, "item"):
            entries.append(entry)
            self.entry = nil
        default:
            break
        }
    }
}
