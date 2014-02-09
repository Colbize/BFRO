//
//  LocationViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 8/27/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationsViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
    NSString *predicateSearch;
    BOOL *USAYN;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (id)initWithFetchResults:(NSString *)pred USAYN:(BOOL *)YN;

@end
