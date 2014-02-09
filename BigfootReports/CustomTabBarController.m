//
//  CustomTabBarController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/26/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "CustomTabBarController.h"
#import "btcAppDelegate.h"

@interface CustomTabBarController ()
@end

@implementation CustomTabBarController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    UINavigationController *moreController = self.moreNavigationController;
    moreController.navigationBar.titleTextAttributes = textAttributes;
    [moreController.navigationBar setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
    [moreController setDelegate:self];
    
    if ([moreController.topViewController.view isKindOfClass:[UITableView class]])
    {
        UITableView *view = (UITableView *)moreController.topViewController.view;
        moreTableViewDataSource = [[MoreTableViewDataSource alloc] initWithDataSource:view.dataSource];
        view.dataSource = moreTableViewDataSource;
        [view setBackgroundColor:[UIColor clearColor]];
        [view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
        [view setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UINavigationController *moreController = self.moreNavigationController;

    if ([moreController.topViewController.view isKindOfClass:[UITableView class]]) {
        [moreController.navigationBar setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
        [[[moreController tabBarController] tabBar] setHidden:NO];
        
        UINavigationItem *morenavitem = moreController.navigationBar.topItem;
        /* We don't need Edit button in More screen. */
        morenavitem.rightBarButtonItem = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
