//
//  NewsFeedViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/13/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedViewController : UITableViewController <UITextViewDelegate>
- (void)fetchTimelineForUser:(NSString *)username;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
