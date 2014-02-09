//
//  WhatisBigfootWebViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/23/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "WebViewController.h"
#import "ImageViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController
@synthesize webView, htmlString, urlString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
    
    webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewWillLayoutSubviews
{
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tabBarController.tabBar setHidden:YES];
    
    [webView setDelegate:self];
    
    NSString *DescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                 "<head> \n"
                                 "<style type=\"text/css\"> img { max-width: 100%; width: auto; height: auto; display: block; margin: 0 auto;}  \n"
                                 "body {font-family: \"%@\"; color:#FFFFFF; font-size: %@;}\n"
                                 "</style> \n"
                                 "</head> \n"
                                 "<body>%@ \n Copyright © 2014 BFRO.net </body>"
                                 "</html>", @"Helvetica Neue", [NSNumber numberWithInt:15], htmlString];
    
    [self.webView loadHTMLString:DescriptionHTML baseURL:[NSURL URLWithString:urlString]];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    webView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    if ([request.URL.scheme isEqualToString:@"http"] && ![request.URL isEqual:[NSURL URLWithString:urlString]]) {
        ImageViewController *ivc = [[ImageViewController alloc] init];
        [ivc setUrl:request.URL];
        [self.navigationController pushViewController:ivc animated:YES];
        
        return NO;
    }
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
