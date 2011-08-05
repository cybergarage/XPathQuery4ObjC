//
//  CGXPathQuery.m
//
//  Created by Satoshi Konno on 11/08/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import <Foundation/NSXMLParser.h>
#import "CGXPathQuery.h"

#define CGXPATHQUERY_PARAM_CHILD					@"children"
#define CGXPATHQUERY_PARAM_ELEMENT_NAME				@"name"
#define CGXPATHQUERY_PARAM_ELEMENT_VALUE			@"value"
#define CGXPATHQUERY_PARAM_ELEMENT_ATTRIBUTES		@"attributes"

@interface CGXPathQuery() <NSXMLParserDelegate>
@property(retain) NSData *xmlData;
@property(retain) NSMutableDictionary *domDictionary;
@property(retain) NSMutableArray *parserStack;
@end

@interface CGXPathObject(CGXPathQueryPrivate)
- (NSArray *)childObjectsForName:(NSString *)name;
- (CGXPathObject *)childObjectForName:(NSString *)name;
- (NSArray *)objectsForXPath:(NSString *)xpath absolute:(BOOL)isAbsoluteXPath;
- (NSArray *)valuesForXPath:(NSString *)absoluteXPath absolute:(BOOL)isAbsoluteXPath;
- (CGXPathObject *)objectForXPath:(NSString *)absoluteXPath absolute:(BOOL)isAbsoluteXPath;
- (NSString *)valueForXPath:(NSString *)absoluteXPath absolute:(BOOL)isAbsoluteXPath;
- (NSArray *)objectsForAbsolutePath:(NSString *)xpath;
- (NSArray *)valuesForAbsolutePath:(NSString *)xpath;
- (CGXPathObject *)objectForAbsolutePath:(NSString *)xpath;
- (NSString *)valueForAbsolutePath:(NSString *)xpath;
- (NSArray *)objectsForRelativePath:(NSString *)xpath;
- (NSArray *)valuesForRelativePath:(NSString *)xpath;
- (CGXPathObject *)objectForRelativePath:(NSString *)xpath;
- (NSString *)valueForRelativePath:(NSString *)xpath;
@end

@implementation CGXPathQuery

@synthesize parserError;
@synthesize xmlData;
@synthesize domDictionary;
@synthesize parserStack;

#pragma mark -
#pragma mark Initialize

- (id)init
{
	if ((self = [super init])) {
	}
	return self;
}

- (id)initWithContentsOfURL:(NSURL *)url
{
	if ((self = [self initWithData:[NSData dataWithContentsOfURL:url]])) {
	}
	return self;
}

- (id)initWithData:(NSData *)data
{
	if ((self = [self init])) {
		[self setXmlData:data];
	}
	return self;
}

-(void)dealloc
{
	[super dealloc];
	
    self.parserError = nil;
    self.xmlData = nil;
    self.domDictionary = nil;
    self.parserStack = nil;
}

#pragma mark -
#pragma mark Parser

- (BOOL)parse
{
	if ([self xmlData] == nil)
		return NO;
	
	[self setParserError:nil];
	
	NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:[self xmlData]];
	[xmlParser setDelegate:self];
	BOOL parseResult = [xmlParser parse];
	[self setParserError:[xmlParser parserError]];
	[xmlParser release];
	
	return parseResult;
}

- (void)pushParserObject:(id)parserObject
{
	[[self parserStack] addObject:parserObject];
}

- (id)peekParserObject
{
	return [[self parserStack] objectAtIndex:([[self parserStack] count] - 1)];
}

- (id)popParserObject
{
	id lastObject = [[self parserStack] objectAtIndex:([[self parserStack] count] - 1)];
	[[self parserStack] removeLastObject];
	return [[lastObject retain] autorelease];
}

#pragma mark -
#pragma mark objectForXPath

- (NSArray *)objectsForXPath:(NSString *)absoluteXPath
{
	return [[self domDictionary] objectsForAbsolutePath:absoluteXPath];
}

- (NSArray *)valuesForXPath:(NSString *)absoluteXPath
{
	return [[self domDictionary] valuesForAbsolutePath:absoluteXPath];
}

- (CGXPathObject *)objectForXPath:(NSString *)absoluteXPath
{
	return [[self domDictionary] objectForAbsolutePath:absoluteXPath];
}

- (NSString *)valueForXPath:(NSString *)absoluteXPath
{
	return [[self domDictionary] valueForAbsolutePath:absoluteXPath];
}

#pragma mark -
#pragma mark Dictionary

- (NSMutableDictionary *)rootDictionary
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:[NSMutableArray array] forKey:CGXPATHQUERY_PARAM_CHILD];
	return dictionary;
}

- (NSMutableDictionary *)childDictionary
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	[dictionary setObject:[NSMutableString string] forKey:CGXPATHQUERY_PARAM_ELEMENT_VALUE];
	[dictionary setObject:[NSMutableArray array] forKey:CGXPATHQUERY_PARAM_CHILD];
	return dictionary;
}

#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
	[self setDomDictionary:[self rootDictionary]];
	[self setParserStack:[NSMutableArray array]];
	[self pushParserObject:[self domDictionary]];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self popParserObject];
	[self setParserStack:nil];
}

/*
- (void)parser:(NSXMLParser *)parser foundNotationDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;

- (void)parser:(NSXMLParser *)parser foundUnparsedEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID notationName:(NSString *)notationName;

- (void)parser:(NSXMLParser *)parser foundAttributeDeclarationWithName:(NSString *)attributeName forElement:(NSString *)elementName type:(NSString *)type defaultValue:(NSString *)defaultValue;

- (void)parser:(NSXMLParser *)parser foundElementDeclarationWithName:(NSString *)elementName model:(NSString *)model;

- (void)parser:(NSXMLParser *)parser foundInternalEntityDeclarationWithName:(NSString *)name value:(NSString *)value;

- (void)parser:(NSXMLParser *)parser foundExternalEntityDeclarationWithName:(NSString *)name publicID:(NSString *)publicID systemID:(NSString *)systemID;
*/

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSMutableDictionary *childDictionary = [self childDictionary];
	[childDictionary setObject:elementName forKey:CGXPATHQUERY_PARAM_ELEMENT_NAME];
	[childDictionary setObject:attributeDict forKey:CGXPATHQUERY_PARAM_ELEMENT_ATTRIBUTES];
	
	NSMutableDictionary *parentDictionary = [self peekParserObject];
	NSMutableArray *parendChildArray = [parentDictionary objectForKey:CGXPATHQUERY_PARAM_CHILD];
	[parendChildArray addObject:childDictionary];
	
	[self pushParserObject:childDictionary];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	[self popParserObject];
}

/*
- (void)parser:(NSXMLParser *)parser didStartMappingPrefix:(NSString *)prefix toURI:(NSString *)namespaceURI;

 - (void)parser:(NSXMLParser *)parser didEndMappingPrefix:(NSString *)prefix;
*/

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	NSMutableDictionary *currentDictionary = [self peekParserObject];
	NSMutableString *elementValue = [currentDictionary objectForKey:CGXPATHQUERY_PARAM_ELEMENT_VALUE];
	[elementValue appendString:string];
}
 
/*
- (void)parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;

- (void)parser:(NSXMLParser *)parser foundProcessingInstructionWithTarget:(NSString *)target data:(NSString *)data;

- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment;

- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock;

- (NSData *)parser:(NSXMLParser *)parser resolveExternalEntityName:(NSString *)name systemID:(NSString *)systemID;

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError;

- (void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError;
*/

@end

#pragma mark -
#pragma mark CGXPathObject

@implementation CGXPathObject(CGXPathQuery) 

- (NSString *)name
{
	return [self objectForKey:CGXPATHQUERY_PARAM_ELEMENT_NAME];
}

- (NSString *)value
{
	return [self objectForKey:CGXPATHQUERY_PARAM_ELEMENT_VALUE];
}

- (NSDictionary *)attributes;
{
	return [self objectForKey:CGXPATHQUERY_PARAM_ELEMENT_ATTRIBUTES];
}

- (NSArray *)children
{
	return [self objectForKey:CGXPATHQUERY_PARAM_CHILD];
}

- (NSArray *)objectsForXPath:(NSString *)relativeXPath
{
	return [self objectsForRelativePath:relativeXPath];
}

- (NSArray *)valuesForXPath:(NSString *)relativeXPath
{
	return [self valuesForRelativePath:relativeXPath];
}

- (CGXPathObject *)objectForXPath:(NSString *)relativeXPath
{
	return [self objectForRelativePath:relativeXPath];
}

- (NSString *)valueForXPath:(NSString *)relativeXPath
{
	return [self valueForRelativePath:relativeXPath];
}

@end

@implementation CGXPathObject(CGXPathQueryPrivate) 

- (NSArray *)childObjectsForName:(NSString *)name
{
	if (name == nil)
		return [NSArray array];
	
	NSArray *childArray = [self children];
	if (childArray == nil)
		return nil;
	
	NSMutableArray *childObjects = [NSMutableArray array];
	for (NSMutableDictionary *childObject in childArray) {
		NSString *elementName = [childObject name];
		if ([name isEqualToString:elementName])
			[childObjects addObject:childObject];
	}
	
	return childObjects;
}

- (CGXPathObject *)childObjectForName:(NSString *)name
{
	NSArray *childObjects = [self childObjectsForName:name];
	if (childObjects == nil || [childObjects count] <= 0)
		return nil;
	return [childObjects objectAtIndex:0];
}

- (NSArray *)objectsForXPath:(NSString *)xpath absolute:(BOOL)isAbsoluteXPath
{
	if (xpath == nil || [xpath length] <= 0)
		return nil;
	
	NSArray *xpathComponets = [xpath pathComponents];
	if ([xpathComponets count] <= 0)
		return nil;
	
	if (isAbsoluteXPath) {
		if ([[xpathComponets objectAtIndex:0] isEqualToString:@"/"] == NO)
			return nil;
		NSMutableArray *relativeXPathComponets = [NSMutableArray arrayWithArray:xpathComponets];
		[relativeXPathComponets removeObjectAtIndex:0];
		xpathComponets = relativeXPathComponets;
	}
	
	int xpathComponetsCount = [xpathComponets count];
	if (xpathComponetsCount <= 0)
		return [NSArray arrayWithObjects:self, nil];
	
	CGXPathObject *xPathObject = self;
	for (int n = 0; n < xpathComponetsCount; n++) {
		NSString *pathName = [xpathComponets objectAtIndex:n];
		if (n == (xpathComponetsCount-1))
			return [xPathObject childObjectsForName:pathName];
		xPathObject = [xPathObject childObjectForName:pathName];
		if (xPathObject == nil)
			return nil;
	}
	
	return nil;
}

- (NSArray *)valuesForXPath:(NSString *)absoluteXPath absolute:(BOOL)isAbsoluteXPath
{
	NSArray *xPathObjects = [self objectsForXPath:absoluteXPath absolute:isAbsoluteXPath];
	if (xPathObjects == nil || [xPathObjects count] <= 0)
		return [NSArray array];
	NSMutableArray *valueArray = [NSMutableArray array];
	for (NSDictionary *xPathObject in xPathObjects)
		[valueArray addObject:[xPathObject value]];
	return valueArray;
}

- (CGXPathObject *)objectForXPath:(NSString *)absoluteXPath absolute:(BOOL)isAbsoluteXPath
{
	NSArray *xPathObjects = [self objectsForXPath:absoluteXPath absolute:isAbsoluteXPath];
	if (xPathObjects == nil || [xPathObjects count] <= 0)
		return nil;
	return [xPathObjects objectAtIndex:0];
}

- (NSString *)valueForXPath:(NSString *)absoluteXPath absolute:(BOOL)isAbsoluteXPath
{
	NSDictionary *xPathObject = [self objectForXPath:absoluteXPath absolute:isAbsoluteXPath];
	if (xPathObject == nil)
		return nil;
	return [xPathObject value];
}

#pragma mark -
#pragma mark For absolute XPath

- (NSArray *)objectsForAbsolutePath:(NSString *)xpath
{
	return [self objectsForXPath:xpath absolute:YES];
}

- (NSArray *)valuesForAbsolutePath:(NSString *)xpath
{
	return [self valuesForXPath:xpath absolute:YES];
}

- (CGXPathObject *)objectForAbsolutePath:(NSString *)xpath
{
	return [self objectForXPath:xpath absolute:YES];
}

- (NSString *)valueForAbsolutePath:(NSString *)xpath
{
	return [self valueForXPath:xpath absolute:YES];
}

#pragma mark -
#pragma mark For relative XPath

- (NSArray *)objectsForRelativePath:(NSString *)xpath
{
	return [self objectsForXPath:xpath absolute:NO];
}

- (NSArray *)valuesForRelativePath:(NSString *)xpath
{
	return [self valuesForXPath:xpath absolute:NO];
}

- (CGXPathObject *)objectForRelativePath:(NSString *)xpath
{
	return [self objectForXPath:xpath absolute:NO];
}

- (NSString *)valueForRelativePath:(NSString *)xpath
{
	return [self valueForXPath:xpath absolute:NO];
}

@end

