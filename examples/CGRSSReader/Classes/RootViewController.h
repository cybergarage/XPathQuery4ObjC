//
//  RootViewController.h
//  CGXPathQueryDemo
//
//  Created by Satoshi Konno on 11/08/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CGXPathQuery.h"

#define CG_XPATHQUERY_RSS_URL @"http://rss.news.yahoo.com/rss/topstories"

@interface RootViewController : UITableViewController {
}
@property(retain) NSArray *rssEntries;
@end
