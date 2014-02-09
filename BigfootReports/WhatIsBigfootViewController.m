//
//  WhatIsBigfootViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/22/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "WhatIsBigfootViewController.h"
#import "WebViewController.h"

@interface WhatIsBigfootViewController ()

@end

@implementation WhatIsBigfootViewController
@synthesize textView;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.tabBarController.tabBar setHidden:YES];
    [textView flashScrollIndicators];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)Anatomy:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"anatomy" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    [webViewController setUrlString:@"http://www.bfro.net/gdb/show_FAQ.asp?id=585"];
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)Physiology:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"physiology" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    [webViewController setUrlString:@"http://www.bfro.net/gdb/show_FAQ.asp?id=586"];
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)Behavior:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"behavior" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    [webViewController setUrlString:@"http://www.bfro.net/gdb/show_FAQ.asp?id=587"];
    
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)Literature:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"literature" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    [webViewController setUrlString:@"http://www.bfro.net/gdb/show_FAQ.asp?id=588"];
    
    [self.navigationController pushViewController:webViewController animated:YES];
}
@end
