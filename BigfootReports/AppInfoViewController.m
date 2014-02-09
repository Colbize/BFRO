//
//  AppInfoViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 12/19/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "AppInfoViewController.h"

@interface AppInfoViewController ()
{
    UIButton *menuButton;
}
@end

@implementation AppInfoViewController

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
    // Do any additional setup after loading the view from its nib.
    
    menuButton = [UIButton buttonWithType:UIButtonTypeSystem];
    menuButton.frame = CGRectMake(0, 0, 38, 44);
    [menuButton setImage:[UIImage imageNamed:@"menuButton"] forState:UIControlStateNormal];
    [menuButton addTarget:self action:@selector(revealMenu) forControlEvents:UIControlEventTouchUpInside];
    [menuButton setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuButton];
    [[self navigationItem] setLeftBarButtonItem:menuItem];

    
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"App Info";
    [self.navigationController.navigationBar setBarTintColor:[UIColor lightGrayColor]];

}

- (void)revealMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];

}
- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
