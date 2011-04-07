//
//  CGXPathQueryTestRSS.m
//  CGXPathQueryDemo
//
//  Created by Satoshi Konno on 11/08/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import "CGXPathQueryTest.h"

@implementation CGXPathQueryTest(RSS100)

/* http://web.resource.org/rss/1.0/spec */
#define CGXPATHQUERYTEST_RSS100_DATA01 \
@"<?xml version=\"1.0\"?>" \
@"<rdf:RDF xmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\" xmlns=\"http://purl.org/rss/1.0/\">" \
@"<channel rdf:about=\"http://www.xml.com/xml/news.rss\">" \
@"<title>XML.com</title>" \
@"<link>http://xml.com/pub</link>" \
@"<description>" \
@"XML.com features a rich mix of information and services " \
@"for the XML community." \
@"</description>" \
@"<image rdf:resource=\"http://xml.com/universal/images/xml_tiny.gif\" />" \
@"<items>" \
@"<rdf:Seq>" \
@"<rdf:li resource=\"http://xml.com/pub/2000/08/09/xslt/xslt.html\" />" \
@"<rdf:li resource=\"http://xml.com/pub/2000/08/09/rdfdb/index.html\" />" \
@"</rdf:Seq>" \
@"</items>" \
@"</channel>" \
@"<image rdf:about=\"http://xml.com/universal/images/xml_tiny.gif\">" \
@"<title>XML.com</title>" \
@"<link>http://www.xml.com</link>" \
@"<url>http://xml.com/universal/images/xml_tiny.gif</url>" \
@"</image>" \
@"<item rdf:about=\"http://xml.com/pub/2000/08/09/xslt/xslt.html\">" \
@"<title>Processing Inclusions with XSLT</title>" \
@"<link>http://xml.com/pub/2000/08/09/xslt/xslt.html</link>" \
@"<description>" \
@"Processing document inclusions with general XML tools can be " \
@"problematic. This article proposes a way of preserving inclusion " \
@"information through SAX-based processing." \
@"</description>" \
@"</item>" \
@"<item rdf:about=\"http://xml.com/pub/2000/08/09/rdfdb/index.html\">" \
@"<title>Putting RDF to Work</title> " \
@"<link>http://xml.com/pub/2000/08/09/rdfdb/index.html</link>" \
@"<description>" \
@"Tool and API support for the Resource Description Framework " \
@"is slowly coming of age. Edd Dumbill takes a look at RDFDB, " \
@"one of the most exciting new RDF toolkits." \
@"</description>" \
@"</item>" \
@"</rdf:RDF>"

- (void) testRSS100 {
    
	CGXPathQuery *xpathQuery;
	
	xpathQuery = [[CGXPathQuery alloc] initWithData:[CGXPATHQUERYTEST_RSS100_DATA01 dataUsingEncoding:NSUTF8StringEncoding]];
	STAssertTrue([xpathQuery parse], @"");
	
	STAssertNil([xpathQuery objectForXPath:nil], @"");
	STAssertNil([xpathQuery objectForXPath:@""], @"");
	
	CGXPathObject *rootObject = [xpathQuery objectForXPath:@"/"];
	STAssertNotNil(rootObject, @"");

	CGXPathObject *rdfObject = [xpathQuery objectForXPath:@"/rdf:RDF"];
	STAssertNotNil(rdfObject, @"");
	NSDictionary *rdfAttributes = [rdfObject attributes];
	STAssertNotNil(rdfAttributes, @"");
	STAssertTrue(([rdfAttributes count] == 2), @"");
	STAssertEqualObjects([rdfAttributes valueForKey:@"xmlns:rdf"], @"http://www.w3.org/1999/02/22-rdf-syntax-ns#", @"");
	STAssertEqualObjects([rdfAttributes valueForKey:@"xmlns"], @"http://purl.org/rss/1.0/", @"");
	
	STAssertEqualObjects([xpathQuery valueForXPath:@"/rdf:RDF/channel/title"], @"XML.com", @"");
	STAssertEqualObjects([xpathQuery valueForXPath:@"/rdf:RDF/channel/link"], @"http://xml.com/pub", @"");

	NSArray *itemObjects = [xpathQuery objectsForXPath:@"/rdf:RDF/item"];
	STAssertTrue(([itemObjects count] == 2), @"");
	
	CGXPathObject *itemObject;
	itemObject = [itemObjects objectAtIndex:0];
	STAssertEqualObjects([itemObject valueForXPath:@"title"], @"Processing Inclusions with XSLT", @"");
	STAssertEqualObjects([itemObject valueForXPath:@"link"], @"http://xml.com/pub/2000/08/09/xslt/xslt.html", @"");
	
	itemObject = [itemObjects objectAtIndex:1];
	STAssertEqualObjects([itemObject valueForXPath:@"title"], @"Putting RDF to Work", @"");
	STAssertEqualObjects([itemObject valueForXPath:@"link"], @"http://xml.com/pub/2000/08/09/rdfdb/index.html", @"");
	
	[xpathQuery release];
}

@end
