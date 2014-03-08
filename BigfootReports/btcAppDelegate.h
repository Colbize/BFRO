//
//  btcAppDelegate.h
//  BigfootReports
//
//  Created by Colby Reineke on 11/24/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabBarController.h"
#import "TWTSideMenuViewController.h"
//#import <Instabug/Instabug.h>

@interface btcAppDelegate : UIResponder <UIApplicationDelegate, TWTSideMenuViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CustomTabBarController *tbc;
@end
