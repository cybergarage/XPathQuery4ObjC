//
//  RootViewController.m
//  CGXPathQueryDemo
//
//  Created by Satoshi Konno on 11/08/02.
//  Copyright 2008 Satoshi Konno. All rights reserved.
//

#import "RootViewController.h"
#import "CGWebViewController.h"

@implementation RootViewController

@synthesize rssEntries;

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	CGXPathQuery *xpathQuery = [[CGXPathQuery alloc] initWithContentsOfURL:[NSURL URLWithString:CG_XPATHQUERY_RSS_URL]];
	if ([xpathQuery parse] == NO)
		return 0;
	
	NSString *title = [xpathQuery valueForXPath:@"/rss/channel/title"];
	if (0 < [title length])
		[self setTitle:title];

	NSArray *entries = [xpathQuery objectsForXPath:@"/rss/channel/item"];
	[self setRssEntries:entries];

    return [[self rssEntries] count];;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	CGXPathObject *xpathObject = [rssEntries objectAtIndex:[indexPath row]];
	if (xpathObject == nil)
		return cell;
	
	[[cell textLabel] setText:[xpathObject valueForXPath:@"title"]];
	
	NSURL *imageUrl = [NSURL URLWithString:[xpathObject valueForXPath:@"image"]];
	if (imageUrl == nil) {
		CGXPathObject *mediaContent = [xpathObject objectForXPath:@"media:content"];
		if (mediaContent != nil)
			imageUrl = [NSURL URLWithString:[[mediaContent attributes] valueForKey:@"url"]];
	}
	
	if (imageUrl != nil)
		[[cell imageView] setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]]];
	
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	
	return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	CGXPathObject *xpathObject = [rssEntries objectAtIndex:[indexPath row]];
	if (xpathObject == nil)
		return;

	NSString *linkUrl = [xpathObject valueForXPath:@"link"];
	if (linkUrl == nil)
		return;
	
	CGWebViewController *detailViewController = [[CGWebViewController alloc] init];
	[detailViewController setTitle:[xpathObject valueForXPath:@"title"]];
	[detailViewController setDocumentURL:[NSURL URLWithString:linkUrl]];
	[self.navigationController pushViewController:detailViewController animated:YES];
	[detailViewController release];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
}

- (void)dealloc {
    [super dealloc];
}

@end

