//
//  EveryReportViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 12/17/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EveryReportViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate, UISearchBarDelegate, UITextFieldDelegate>
{
    NSString *titleName;
    bool viewLoadedAlreadyYN;
}
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (strong, nonatomic) UIButton *menuButton;
@property (strong, nonatomic) IIViewDeckController *iivdc;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *goToTop;
@property (weak, nonatomic) IBOutlet UILabel *noReportsLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (strong, nonatomic) IBOutlet UIView *searchByDate;
@property (weak, nonatomic) IBOutlet UITextField *fromDate;
@property (weak, nonatomic) IBOutlet UITextField *toDate;

- (IBAction)searchDate:(id)sender;
- (IBAction)cancelDate:(id)sender;

- (IBAction)goToTop:(id)sender;

- (id)initwithSearchRequest;
- (id)initwithFetchRequest:(NSFetchRequest *)fRequest titleName:(NSString *)tn;
- (void)sortResults;
@end
