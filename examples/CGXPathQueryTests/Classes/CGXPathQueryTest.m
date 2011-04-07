//
//  CGXPathQueryTest.m
//  CGXPathQueryDemo
//
//  Created by Satoshi Konno on 11/08/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import "CGXPathQueryTest.h"


@implementation CGXPathQueryTest

#if USE_APPLICATION_UNIT_TEST     // all code under test is in the iPhone Application

- (void) testAppDelegate {
    
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
    
}

#endif


@end
