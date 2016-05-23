//
//  PrivacyView.m
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//

#import "fileutil.h"

#import "PrivacyView.h"
@interface PrivacyView()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end


@implementation PrivacyView

@synthesize webView;

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = @"Privacy Policy";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	webView.frame = self.view.bounds;

	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:Applications(@"privacy.html")]]];
}

@end
