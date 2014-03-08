//
//  ChooseReportLocationViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/29/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseReportLocationViewController : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseLocation;
- (IBAction)chooseLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
