//
//  main.m
//  CGXPathPrint
//
//  Created by Satoshi Konno on 11/03/03.
//  Copyright 2011 Satoshi Konno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CGXPathQuery.h"

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

NSString *IndentString(int indent)
{
	NSMutableString *indentString = [NSMutableString string];
	for (int n=0; n<(indent-1); n++)
		[indentString appendString:@"\t"];
	return indentString;
}

BOOL IsRootNode(CGXPathObject *xpathObject)
{
	return [xpathObject name] ? NO : YES;
}

void XPathQueryPrint(CGXPathObject *xpathObject, int indent)
{
	if (!IsRootNode(xpathObject)) {
		printf("%s<%s", [IndentString(indent) UTF8String], [[xpathObject name] UTF8String]);
		for (NSString *attributeKey in [[xpathObject attributes] allKeys]) {
			printf(" %s=\"%s\"", [attributeKey UTF8String], [[[xpathObject attributes] valueForKey:attributeKey] UTF8String]);
		}
		printf(">");
	}
	
	if (0 < [[xpathObject children] count]) {
		printf("\n");
		for (CGXPathObject *childXPathObject in [xpathObject children])
			XPathQueryPrint(childXPathObject, (indent+1));
		if (!IsRootNode(xpathObject))
			printf("%s</%s>\n", [IndentString(indent) UTF8String], [[xpathObject name] UTF8String]);
		return;
	}

	if (!IsRootNode(xpathObject)) {
		if ([xpathObject value]) {
			printf("%s", [[xpathObject value] UTF8String]);
		}
		printf("</%s>\n", [[xpathObject name] UTF8String]);
	}
}

int main(int argc, char *argv[]) 
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	CGXPathQuery *xpathQuery = [[CGXPathQuery alloc] initWithData:[CGXPATHQUERYTEST_RSS100_DATA01 dataUsingEncoding:NSUTF8StringEncoding]];
	if ([xpathQuery parse])
		XPathQueryPrint([xpathQuery objectForXPath:@"/"], 0);
	[xpathQuery release];
	
    [pool release];
	
    return 0;
}
