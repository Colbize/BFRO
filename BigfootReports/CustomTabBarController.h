//
//  CustomTabBarController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/26/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreTableViewDataSource.h"

@interface CustomTabBarController : UITabBarController 
{
    MoreTableViewDataSource *moreTableViewDataSource;
}
@property UINavigationController *moreControllerClass;
@property (retain) id<UITableViewDataSource> originalDataSource;
@end
