//
//  CGXPathQuery.h
//
//  Created by Satoshi Konno on 11/08/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface CGXPathQuery : NSObject {

}
@property(retain) NSError *parserError;
- (id)init;
- (id)initWithContentsOfURL:(NSURL *)url;
- (id)initWithData:(NSData *)data;
- (BOOL)parse;
- (NSArray *)objectsForXPath:(NSString *)absoluteXPath;
- (CGXPathObject *)objectForXPath:(NSString *)absoluteXPath;
- (NSArray *)valuesForXPath:(NSString *)absoluteXPath;
- (NSString *)valueForXPath:(NSString *)absoluteXPath;
@end
