//
//  FAQViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/20/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "FAQViewController.h"
#import "wasntThisFakeViewController.h"
#import "physicalEvidenceViewController.h"
#import "WhatIsBigfootViewController.h"
#import "WebViewController.h"

@interface FAQViewController ()
{
}
@end

@implementation FAQViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationController.navigationBar.translucent = NO;

    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"BFRO FAQs";
    
    [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)aboutBFRO:(id)sender {
    UIViewController *aboutBFRO = [[UIViewController alloc] initWithNibName:@"AboutBFRO" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    aboutBFRO.title = @"About The BFRO";
    [self.navigationController pushViewController:aboutBFRO animated:YES];
}

- (IBAction)wasntThisFake:(id)sender
{
    wasntThisFakeViewController *wtfvc = [[wasntThisFakeViewController alloc] init];
    wtfvc.title = @"Wasn't This Fake?";
    [self.navigationController pushViewController:wtfvc animated:YES];
}

- (IBAction)hoaxes:(id)sender {
    UIViewController *hoaxes = [[UIViewController alloc] initWithNibName:@"Hoax" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    hoaxes.title = @"Report Hoaxing?";
    [self.navigationController pushViewController:hoaxes animated:YES];
}

- (IBAction)physicalEvidence:(id)sender {
    physicalEvidenceViewController *physical = [[physicalEvidenceViewController alloc] init];
    physical.title = @"Where is the Evidence?";
    [self.navigationController pushViewController:physical animated:YES];
}

- (IBAction)whatIsBigfoot:(id)sender {
    WhatIsBigfootViewController *wibvc = [[WhatIsBigfootViewController alloc] init];
    wibvc.title = @"What is Bigfoot?";
    [self.navigationController pushViewController:wibvc animated:YES];

}

- (IBAction)comeFrom:(id)sender {
    WebViewController *webViewController = [[WebViewController alloc] init];
    [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"comeFrom" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    [webViewController setUrlString:@"http://www.bfro.net/REF/THEORIES/MJM/whatrtha.asp"];
    webViewController.title = @"Where do they come from?";
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (IBAction)howMany:(id)sender {
    UIViewController *aboutBFRO = [[UIViewController alloc] initWithNibName:@"HowMany" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    aboutBFRO.title = @"How Many?";
    [self.navigationController pushViewController:aboutBFRO animated:YES];
}

- (IBAction)buryDead:(id)sender {
    UIViewController *aboutBFRO = [[UIViewController alloc] initWithNibName:@"BuryDead" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    aboutBFRO.title = @"Bury The Dead?";
    [self.navigationController pushViewController:aboutBFRO animated:YES];
}

- (IBAction)areTheyDangerous:(id)sender {
    UIViewController *aboutBFRO = [[UIViewController alloc] initWithNibName:@"Dangerous" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    aboutBFRO.title = @"Are They Dangerous?";
    [self.navigationController pushViewController:aboutBFRO animated:YES];
}

- (IBAction)recognizeThem:(id)sender {
    UIViewController *aboutBFRO = [[UIViewController alloc] initWithNibName:@"recognizeThem" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    aboutBFRO.title = @"Recognize Them?";
    [self.navigationController pushViewController:aboutBFRO animated:YES];
}

- (IBAction)climbTrees:(id)sender {
    UIViewController *aboutBFRO = [[UIViewController alloc] initWithNibName:@"climbTrees" bundle:nil];
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    aboutBFRO.title = @"Climb Trees?";
    [self.navigationController pushViewController:aboutBFRO animated:YES];
}
@end
