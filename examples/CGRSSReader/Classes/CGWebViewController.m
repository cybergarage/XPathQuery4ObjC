//
//  CGWebViewController.m
//
//  Created by Satoshi Konno on 10/06/24.
//  Copyright 2010 Satoshi Konno. All rights reserved.
//

#import "CGWebViewController.h"

@interface CGWebViewController () 
@property  (retain) UIWebView *webView;
-(void)reloadDocument;
@end

@implementation CGWebViewController

@synthesize documentURL;
@synthesize webView;

- (void)loadView 
{
	CGRect scrSize = [[UIScreen mainScreen] applicationFrame];
	scrSize.origin.y = 0;
	
	self.view = [[UIView alloc] initWithFrame:scrSize];
	webView = [[UIWebView alloc] initWithFrame:[self.view frame]];
	webView.scalesPageToFit = YES;
	[self.view addSubview: webView];
	
	[self.view setAutoresizesSubviews:YES];
	[self.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	[webView setAutoresizesSubviews:YES];
	[webView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
	
	[self.view sizeToFit];
	[webView sizeToFit];
}

- (void)viewDidLoad 
{
	[super viewDidLoad];
	[self reloadDocument];
}

-(void)reloadDocument
{
	[webView loadRequest:[NSURLRequest requestWithURL:[self documentURL]]];
}

@end
