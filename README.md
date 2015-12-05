# Feeder

[![CI Status](http://img.shields.io/travis/tnantoka/Feeder.svg?style=flat)](https://travis-ci.org/tnantoka/Feeder)
[![Version](https://img.shields.io/cocoapods/v/Feeder.svg?style=flat)](http://cocoapods.org/pods/Feeder)
[![License](https://img.shields.io/cocoapods/l/Feeder.svg?style=flat)](http://cocoapods.org/pods/Feeder)
[![Platform](https://img.shields.io/cocoapods/p/Feeder.svg?style=flat)](http://cocoapods.org/pods/Feeder)

## Usage

```swift
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
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Feeder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Feeder"
```

## Author

tnantoka, tnantoka@bornneet.com

## License

Feeder is available under the MIT license. See the LICENSE file for more info.
