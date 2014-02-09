//
//  physicalEvidenceViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/22/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "physicalEvidenceViewController.h"
#import "ImageViewController.h"

@interface physicalEvidenceViewController ()

@end

@implementation physicalEvidenceViewController
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    ImageViewController *ivc = [[ImageViewController alloc] init];
    [ivc setUrl:URL];
    ivc.edgesForExtendedLayout = UIRectEdgeNone;
    ivc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ivc animated:YES];
    
    return NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [textView setDelegate:self];
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
