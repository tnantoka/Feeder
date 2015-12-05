//
//  ViewController.swift
//  Feeder
//
//  Created by tnantoka on 11/19/2015.
//  Copyright (c) 2015 tnantoka. All rights reserved.
//

import UIKit
import Feeder

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        Feeder.shared.find("https://github.com/blog") { page, error in
            print(error) // nil
            
            print(page.title) // The GitHub Blog · GitHub
            print(page.href) // https://github.com/blog
            
            print(page.feeds.count) // 3
            
            print(page.feeds[0]) // Feed(format: .Atom, href: "https://github.com/blog.atom", title: "The GitHub Blog’s featured posts")
            print(page.feeds[1]) // Feed(format: .Atom: "https://github.com/blog/all.atom", title: "The GitHub Blog: All posts")
            print(page.feeds[2]) // Feed(format: .Atom: "https://github.com/blog/broadcasts.atom", title: "The GitHub Blog: Broadcasts only")
        }
        
        Feeder.shared.parse("https://github.com/blog.atom") { entries, error in
            print(error) // nil

            print(entries.count) // 15
            
            print(entries[0]) // Entry(title: "A new look for repositories", href: "https://github.com/blog/2085-a-new-look-for-repositories", summary: "<p>Repositories on GitHub are about to get a brand new look...")
            print(entries[1]) // Entry(title: "Introducing: 3\" Octocat figurine", href: "https://github.com/blog/2084-introducing-3-octocat-figurine", summary: "<p>From the makers of the 5\" Octocat figurine comes the adorably small 3\" Octocat figurine...")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

