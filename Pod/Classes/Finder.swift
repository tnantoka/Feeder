//
//  Finder.swift
//  Pods
//
//  Created by Tatsuya Tobioka on 11/19/15.
//
//

import Foundation

class Finder: NSObject, NSXMLParserDelegate {
    
    let url: NSURL
    let callback: Feeder.FinderCallback
    
    var parser: NSXMLParser!
    var data: NSData!
    
    var format: Format?
    var elementName: String?
    var page = Page()
    
    init(urlString: String, callback: Feeder.FinderCallback) {
        url = NSURL(string: urlString)!
        self.callback = callback
        super.init()
        
        let task = Feeder.shared.session.dataTaskWithURL(url) { data, response, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let data = data {
                    self.parser = NSXMLParser(data: data)
                    self.data = data

                    self.parser.delegate = self
                    self.parser.parse()
                } else {
                    self.callback(self.page, error)
                }
            }
        }
        task.resume()
    }
    
    // MARK: Utility
    
    func absoluteURLString(href: String) -> String {
        let urlString: String
        
        let baseURL = NSURL(string: "\(url.scheme)://\(url.host!)/")!
        
        if href.hasPrefix("//") {
            urlString = "\(baseURL.scheme):\(href)"
        } else if href.hasPrefix("/") || href.hasPrefix(".") {
            urlString = NSURL(string: href, relativeToURL: baseURL)!.absoluteString
        } else {
            urlString = href
        }

        return urlString
    }
    
    // MARK: NSXMLParserDelegate
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        self.elementName = elementName

        switch elementName {
        case "link":
            switch format {
            case nil:
                guard let rel = attributeDict["rel"] where rel.hasPrefix("alternat") else { return }
                
                guard let type = attributeDict["type"] else { return }
                guard let format = Format(contentType: type) else { return }
                
                guard let href = attributeDict["href"] else { return }
                
                let urlString = absoluteURLString(href)
                
                let title = attributeDict["title"] ?? ""
                
                let feed = Feed(format: format, href: urlString, title: title)
                page.feeds.append(feed)
                
                page.href = url.absoluteString
            case .Atom?:
                if page.href.isEmpty {
                    guard let href = attributeDict["href"] else { return }
                    page.href = href
                }
            default:
                break
            }
        case "feed":
            format = .Atom
        case "rss":
            format = .RSS
        case "rdf:RDF":
            format = .RDF
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, foundCharacters string: String) {
        switch (format, elementName) {
        case (nil, "title"?):
            page.title += string
        case (.Some(let format), "title"?):
            if page.title.isEmpty {
                page.title = string                
            }
            if page.feeds.isEmpty {
                let feed = Feed(format: format, href: url.absoluteString, title: "")
                page.feeds = [feed]
            }
        case (.RSS?, "link"?), (.RDF?, "link"?):
            if page.href.isEmpty {
                page.href = string
            }
        default:
            break
        }
    }
    
    func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        self.elementName = ""
    }
    
    func parserDidEndDocument(parser: NSXMLParser) {
        callback(page, nil)
    }
    
    // TODO use var for feed
    // TODO parse remainings
    
    func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
        //print(parseError.localizedDescription)
        if page.feeds.isEmpty {
            page.href = url.absoluteString
            
            guard let html = String(data: data, encoding: NSUTF8StringEncoding) else { return callback(page, nil) }

            if page.title.isEmpty {
                guard let titleRegexp = try? NSRegularExpression(pattern: "<title>(.+?)</title>", options: .CaseInsensitive) else { return }
                if let result = titleRegexp.firstMatchInString(html, options: [], range: NSMakeRange(0, html.characters.count)) {
                    page.title = (html as NSString).substringWithRange(result.rangeAtIndex(1))
                }                
            }
            
            guard let linkRegexp = try? NSRegularExpression(pattern: "<link[^>]*>", options: .CaseInsensitive) else { return callback(page, nil) }
            linkRegexp.enumerateMatchesInString(html, options: [], range: NSMakeRange(0, html.characters.count)) { result, _, _ in
                guard let result = result else { return }
                let link = (html as NSString).substringWithRange(result.range)
                if let _ = link.rangeOfString("alternat") {
                    var title = ""
                    guard let titleRegexp = try? NSRegularExpression(pattern: "title=\"(.+?)\"", options: .CaseInsensitive) else { return }
                    if let result = titleRegexp.firstMatchInString(link, options: [], range: NSMakeRange(0, link.characters.count)) {
                        title = (link as NSString).substringWithRange(result.rangeAtIndex(1))
                    }
                    
                    var href = ""
                    guard let hrefRegexp = try? NSRegularExpression(pattern: "href=\"(.+?)\"", options: .CaseInsensitive) else { return }
                    if let result = hrefRegexp.firstMatchInString(link, options: [], range: NSMakeRange(0, link.characters.count)) {
                        href = (link as NSString).substringWithRange(result.rangeAtIndex(1))
                    }

                    guard let typeRegexp = try? NSRegularExpression(pattern: "type=\"(.+?)\"", options: .CaseInsensitive) else { return }
                    if let result = typeRegexp.firstMatchInString(link, options: [], range: NSMakeRange(0, link.characters.count)) {
                        let type = (link as NSString).substringWithRange(result.rangeAtIndex(1))
                        if let format = Format(contentType: type) {
                            let feed = Feed(format: format, href: self.absoluteURLString(href), title: title)
                            self.page.feeds.append(feed)
                        }
                    }
                }
            }
            
            callback(page, nil)
        } else {
            callback(page, nil)            
        }
    }
}