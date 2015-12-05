//
//  Format.swift
//  Pods
//
//  Created by Tatsuya Tobioka on 11/19/15.
//
//

public enum Format {
    case Atom, RSS, RDF
    
    init?(contentType: String) {
        switch contentType {
        case "application/atom+xml":
            self = .Atom
        case "application/rss+xml":
            self = .RSS
        case "application/rdf+xml":
            self = .RDF
        default:
            return nil
        }
    }
}
