//
//  CGRSSReaderAppDelegate.h
//  CGRSSReader
//
//  Created by Satoshi Konno on 11/03/03.
//  Copyright 2011 Yahoo Japan Corporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CGRSSReaderAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

