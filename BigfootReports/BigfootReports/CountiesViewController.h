//
//  CountiesViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 8/27/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountiesViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSString *stateName;
}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithStateName:(NSString *)sn;

@end
