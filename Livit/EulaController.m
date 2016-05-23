//
//  EulaController.m
//  Livit
//
//  Created by Nathan on 2/20/16.
//  Copyright © 2016 Nathan. All rights reserved.
//

#import "EulaController.h"
#import "fileutil.h"

@interface EulaController ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *acceptButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *ignoreButton;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation EulaController
@synthesize webView;
- (void)ignoreAction:(UIBarButtonItem *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@NO forKey:@"EULA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)acceptAction:(UIBarButtonItem *)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"EULA"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.ignoreButton setTarget:self];
    [self.ignoreButton setAction:@selector(ignoreAction:)];
    [self.acceptButton setTarget:self];
    [self.acceptButton setAction:@selector(acceptAction:)];
    self.title = @"Terms";
    
    
    //webView.frame = [UIScreen mainScreen].bounds;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:Applications(@"terms.html")]]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
