//
//  TermsView.m
//  Livit
//
//  Created by Nathan on 9/19/15.
//  Copyright (c) 2015 Nathan. All rights reserved.
//

#import "fileutil.h"

#import "TermsView.h"

@interface TermsView()

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation TermsView

@synthesize webView;

- (void)viewDidLoad

{
	[super viewDidLoad];
	self.title = @"Terms of Service";
}

- (void)viewWillAppear:(BOOL)animated

{
	[super viewWillAppear:animated];
    webView.frame = [UIScreen mainScreen].bounds;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:Applications(@"terms.html")]]];
}

@end
