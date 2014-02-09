//
//  btcAppDelegate.h
//  BigfootReports
//
//  Created by Colby Reineke on 11/24/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

@interface btcAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) IIViewDeckController *iivdc;
@end
