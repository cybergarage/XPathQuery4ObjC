# XPathQuery for ObjC

## Introduction

XPathQuery4ObjC is a wrapper class for [NSXMLParser]([http://developer.apple.com/library/mac/#documentation/Cocoa/Reference/Foundation/Classes/NSXMLParser_Class/Reference/Reference.html]) to query XML documents such as Web API responses with [XPath](http://www.w3.org/TR/xpath/) more easily.

I know that some wrapper classes for Objective-C was already released such as [XPathQuery](http://cocoawithlove.com/2008/10/using-libxml2-for-parsing-and-xpath.html). However, these are not appropriate to use for me because I would like to query more directly using XPath and these wrappers have some bugs :-(

I have developed other my original DOM parsers which are implemented using some native XML parsers such as Xerese, libxml2 and expat on !MacOSX and iOS platforms, but I decided to use NSXMLParser to implement XPathQuery because I know that it is difficult to support all XML features using the native XML parsers. Please check CyberLinkForC, or CyberLinkForCC and CyberX3DForCC if you want to know other my DOM parsers in more detail.

For example, you can query XML element nodes in Web API responses such as [Media RSS](http://en.wikipedia.org/wiki/Media_RSS) using the XPathQuery as the following.

```
NSURL *rssURL = [NSURL URLWithString:@"http://rss.news.yahoo.com/rss/topstories"];
CGXPathQuery *xpathQuery = [[CGXPathQuery alloc] initWithContentsOfURL:rssURL];

if ([xpathQuery parse] == YES) {
    NSString *title = [xpathQuery valueForXPath:@"/rss/channel/title"];
        ..........
    NSArray *entries = [xpathQuery objectsForXPath:@"/rss/channel/item"];
    for (CGXPathObject *xpathObject in entries) {
        NSString *entryTitle = [xpathObject valueForXPath:@"title"];
            ..........
        NSURL *linkUrl = [NSURL URLWithString:[xpathObject valueForXPath:@"link"]];
            ..........
        NSString *imageUrl = nil;
        CGXPathObject *mediaContent = [xpathObject objectForXPath:@"media:content"];
        if (mediaContent != nil) {
            imageUrl = [NSURL URLWithString:[[mediaContent attributes] valueForKey:@"url"]];
        }
            ..........
    }
}
```

![ctb_java3d_browser](http://www.cybergarage.org/wp-content/uploads/xpathquery_ios_rsssample.png)

## Installation

To use XPathQuery on your XCode project, you have to only add [the two files]([https://github.com/cybergarage/CGXPathQuery/tree/master/CGXPathQuerySDK]), XPathQuery.h and CGXPathQuety.m, into your project :-)

## Classes

XPathQuery is composed of the following two classes, XPathQuery and CGXPathObject.

### CGXPathQuery

XPathQuery is a base class to parse XML documents, you have to initialize with the XML data or the URL. You have to use absolute !XPaths to pass the methods such as objectForXPath:.

```
@interface CGXPathQuery : NSObject {
}
@property(retain) NSError *parserError;
- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (BOOL)parse;
- (NSArray *)objectsForXPath:(NSString *)absoluteXPath;
- (CGXPathObject *)objectForXPath:(NSString *)absoluteXPath;
- (NSArray *)valuesForXPath:(NSString *)absoluteXPath;
- (NSString *)valueForXPath:(NSString *)absoluteXPath;
@end
```

### CGXPathObject

CGXPathObject is a base object of XPathQuery response. CGXPathObject extends NSDictionary to add some useful methods using a category interface. You have to use relative !XPaths to pass the methods such as objectForXPath:.

```
#define CGXPathObject NSDictionary
@interface CGXPathObject(CGXPathQuery)
- (NSArray *)children;
- (NSString *)name;
- (NSString *)value;
- (NSDictionary *)attributes;
- (NSArray *)objectsForXPath:(NSString *)relativeXPath;
- (CGXPathObject *)objectForXPath:(NSString *)relativeXPath;
- (NSArray *)valuesForXPath:(NSString *)relativeXPath;
- (NSString *)valueForXPath:(NSString *)relativeXPath;
@end
```

## Limitation

XPathQuery supports only the following simple !XPath specification which is minimal subset of [XPath](http://www.w3.org/TR/xpath/), and it doesn't support the complex specifications currently.

```
LocationPath ::= RelativeLocationPath
                 | AbsoluteLocationPath

AbsoluteLocationPath ::= '/' RelativeLocationPath

RelativeLocationPath ::= ElementName
                       | RelativeLocationPath '/' ElementName

ElementName ::= [a-zA-Z0-9]+
```

Additionally, XPathQuery doesn't support traversal queries which jumps the parent element. For example, the following code get only a first title element instead of all title elements..

#### XML document

```
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0" Ö..>
Ö..
<item>
    <title>...</title>
    .....
</item>
<item>
    <title>...</title>
    .....
</item>
</rss>
```

#### Inappropriate Code

```
CGXPathQuery *xpathQuery = [[CGXPathQuery alloc] initWithContentsOfURL:rssURL];
if ([xpathQuery parse] == YES) {
    NSArray *itemTitles = [xpathQuery objectsForXPath:@"/rss/channel/item/title"];
    for (CGXPathObject *titleObject in itemTitles) {
        NSString *title = [titleObject value];
        .....
    }
}
```

#### Appropriate Code

To get all title elements normally, use the following steps.

```
CGXPathQuery *xpathQuery = [[CGXPathQuery alloc] initWithContentsOfURL:rssURL];
if ([xpathQuery parse] == YES) {
    NSArray *items = [xpathQuery objectsForXPath:@"/rss/channel/item"];
    for (CGXPathObject *itemObject in entries) {
        NSString *title = [itemObject valueForXPath:@"title"];
        .....
    }
}
```

## Resources

### Repositories

Please see the following pages on GitHub to get the source codes with the examples such as a simple RSS reader :-)

- [GitHub](https://github.com/cybergarage/XPathQuery4ObjC)
- [Doxygen](http://www.cybergarage.org:8080/doxygen/xpathquery4objc/)
