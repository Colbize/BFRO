//
//  EveryReportViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 12/17/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "EveryReportViewController.h"
#import "reportCell.h"
#import "ReportsByLocation.h"
#import "Location.h"
#import "USACountiesByLocation.h"
#import "ReportsViewController.h"
#import "TFHpple.h"
#import <QuartzCore/QuartzCore.h>

@interface EveryReportViewController ()
{
    NSMutableDictionary *favoritesDic;
    BOOL includeSearchBar;
    UIActivityIndicatorView *aivew;
    UIBarButtonItem *dateButton;
    UIBarButtonItem *clearButton;
    UIBarButtonItem *sortButton;
    BOOL searchDatePresent;
    UIDatePicker *datePicker;
    UITextField *currentTextField;
}
@end

@implementation EveryReportViewController
@synthesize fetchedResultsController, fetchRequest, menuButton, tableView, goToTop, noReportsLabel, searchbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initwithFetchRequest:(NSFetchRequest *)fRequest titleName:(NSString *)tn
{
    if (self) {
        fetchRequest = fRequest;
        titleName = tn;
    }
    return self;
}

- (id)initwithSearchRequest
{
    if (self) {
        NSFetchRequest *fRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"dateOfSighting" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(link = %@)", @"BLANK"];
        
        [fRequest setPredicate:predicate];
        [fRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fRequest setEntity:entity];
        
        fetchRequest = fRequest;
        includeSearchBar = YES;
    }
    return self ;
}

# pragma mark - tableView methods

- (UITableViewCell *)tableView:(UITableView *)tv
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the new or recycled cell
    UITableViewCell  *cell = [tableView dequeueReusableCellWithIdentifier:@"reportCell"];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"reportCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    [self configureCell:(reportCell*)cell atIndexPath:indexPath];


    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180.0;
}

- (void)configureCell:(reportCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    
    UIColor * color = [UIColor colorWithRed:127/255.0f green:127/255.0f blue:127/255.0f alpha:1.0f];
    
    [cell setBackgroundColor:[UIColor colorWithRed:31/255.0f green:33/255.0f blue:36/255.0f alpha:1.0f]];//[UIColor colorWithRed:31/255.0f green:33/255.0f blue:36/255.0f alpha:1.0f]];
    
    [cell.layer setCornerRadius:20.0f];
    [cell.layer setMasksToBounds:YES];
    [cell.layer setBorderWidth:2.0f];
    [cell.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMMM yyyy"];
    
    ReportsByLocation *info = [fetchedResultsController objectAtIndexPath:indexPath];
    [cell.reportID setText:[@"Report ID: " stringByAppendingString:info.reportID]];
    
    if (info.dateOfSighting) {
        [cell.date setText:[dateFormatter stringFromDate:info.dateOfSighting]];
    } else {
        [cell.date setText:@"Unknown"];
    }
    
    [cell.shortDesc setText:[NSString stringWithFormat:@"\"%@\"", info.shortDesc]];
    cell.shortDesc.adjustsFontSizeToFitWidth = YES;
    
    if ([info.usaCountyReports.location.country isEqualToString:@"USA"]) {
        [cell.location setText:[NSString stringWithFormat:@"%@, %@", info.usaCountyReports.name, info.usaCountyReports.location.name]];
    } else {
        [cell.location setText:info.reportsByLocation.name];
    }
    
    if ([info.classSighting isEqualToString:@"Class A"]) {
        [cell.classID setBackgroundColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
        [cell.classID setText:@"A"];
    } else if ([info.classSighting isEqualToString:@"Class B"]) {
        [cell.classID setBackgroundColor:[UIColor colorWithRed:255/255.0f green:186/255.0f blue:77/255.0f alpha:1.0f]];
        [cell.classID setText:@"B"];
    } else if ([info.classSighting isEqualToString:@"Class C"]) {
        [cell.classID setBackgroundColor:[UIColor colorWithRed:151/255.0f green:197/255.0f blue:252/255.0f alpha:1.0f]];
        [cell.classID setText:@"C"];;
    }
    
    [cell classID].layer.cornerRadius = 2.0;
    [cell classID].clipsToBounds = YES;
        
    if (!([info.reportHTML.uppercaseString rangeOfString:@"JPG"].location == NSNotFound)) {
        
        [cell.containsPicturesYN setImage:[self imageWithColor:[UIColor whiteColor] withImage:[UIImage imageNamed:@"photo"]]];
    }
    
    if (favoritesDic) {
        if ([favoritesDic objectForKey:info.reportID]) {
            [cell.favoritedYN setImage:[self imageWithColor:[UIColor redColor] withImage:[UIImage imageNamed:@"hearts"]]];
        }
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:info.reportID]) {
        [cell.read setImage:[self imageWithColor:[UIColor whiteColor] withImage:[UIImage imageNamed:@"read_message"]]];
    } else {
        [cell.read setImage:[self imageWithColor:[UIColor whiteColor] withImage:[UIImage imageNamed:@"message"]]];
    }
    
    if (info.latitude && info.longitude) {
        [cell.hasLocation setImage:[self imageWithColor:[UIColor whiteColor] withImage:[UIImage imageNamed:@"location"]]];
    }
    
}

- (void)tableView:(UITableView *)TableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ReportsByLocation *info = [fetchedResultsController objectAtIndexPath:indexPath];
    ReportsViewController *rvc = [[ReportsViewController alloc] init];
    [rvc setReportInfo:info];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    rvc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rvc animated:YES];
   
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:info.reportID];
    
    NSMutableDictionary *recentlyAdded = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] mutableCopy];
    [recentlyAdded removeObjectForKey:info.reportID];
    [[NSUserDefaults standardUserDefaults] setObject:recentlyAdded forKey:@"RecentlyAdded"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return titleName;
    else return @"";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

# pragma mark - NSFetchedResultsController methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                  managedObjectContext:[[BFROStore sharedStore] context]
                                                                                                    sectionNameKeyPath:@"reportID"
                                                                                                             cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    fetchedResultsController.delegate = self;
    
    return fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
    
}

# pragma mark - sort
- (void)sortResults
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Sort Current Results By:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Date Asc", @"Date Desc", @"Class Asc", @"Class Desc", @"Location Name", @"Reset Order", nil];
    
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

# pragma mark - Alert Methods
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSArray *sortDescriptors;
    
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Date Asc"]) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateOfSighting" ascending:YES];
        sortDescriptors = [NSArray arrayWithObject: sort];
        
    } else if ([title isEqualToString:@"Date Desc"]) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"dateOfSighting" ascending:NO];
        sortDescriptors = [NSArray arrayWithObject: sort];
        
    } else if ([title isEqualToString:@"Class Asc"]) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"classSighting" ascending:YES];
        sortDescriptors = [NSArray arrayWithObject: sort];
        
    } else if ([title isEqualToString:@"Class Desc"]) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"classSighting" ascending:NO];
        sortDescriptors = [NSArray arrayWithObject: sort];
        
    } else if ([title isEqualToString:@"Location Name"]) {
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"usaCountyReports.location.name" ascending:YES];
        NSSortDescriptor *sort2 = [NSSortDescriptor sortDescriptorWithKey:@"reportsByLocation.name" ascending:YES];

        sortDescriptors = [NSArray arrayWithObjects: sort, sort2, nil];
        
    } else if ([title isEqualToString:@"Reset Order"]) {
        
    } else if ([title isEqualToString:@"Cancel"]) {
        return;
    }
    [[fetchedResultsController fetchRequest] setSortDescriptors:sortDescriptors];
    
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle you error here
    }
    
    [self.tableView reloadData];
}

# pragma mark - reveal menu
- (void)revealMenu
{
    [self.viewDeckController openLeftViewBouncing:^(IIViewDeckController *controller){
    }];
}


# pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y >= 200) {
        [goToTop setHidden:NO];
        
        searchbar.hidden = (includeSearchBar == YES) ? YES:YES;
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:UIStatusBarAnimationNone];
        [self.tabBarController.tabBar setHidden:YES];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    
    if (scrollView.contentOffset.y <= 10) {
        [goToTop setHidden:YES];
        
        [searchbar setHidden:NO];
        
        searchbar.hidden = (includeSearchBar == YES) ? NO:YES;

        [self.tabBarController.tabBar setHidden:NO];


        [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                withAnimation:UIStatusBarAnimationSlide];

        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

# pragma mark - view load methods
- (void)viewWillLayoutSubviews
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillAppear:(BOOL)animated
{
    clearButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear"
                                                   style:UIBarButtonItemStylePlain
                                                  target:self action:@selector(deleteSearchResults)];
    
    [clearButton setTintColor:self.view.tintColor];
    
    [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:31/255.0f green:33/255.0f blue:36/255.0f alpha:1.0f]];
    
    [self.tableView setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
        
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

    [self.tabBarController.tabBar setHidden:NO];

    [goToTop setHidden:YES];
    [noReportsLabel setHidden:YES];
    
    favoritesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] mutableCopy];
    
    [self.tableView reloadData];
    
    if (viewLoadedAlreadyYN == YES) {
        
        if (self.fetchedResultsController.fetchedObjects.count == 0  && includeSearchBar != YES)
        {
            [noReportsLabel setHidden:NO];
            
            self.tableView.separatorColor = [UIColor clearColor];
            
            UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            
            UIColor* textColor = [UIColor lightGrayColor];
            
            NSDictionary *attrs = @{ NSForegroundColorAttributeName : textColor,
                                     NSFontAttributeName : font,
                                     NSTextEffectAttributeName : NSTextEffectLetterpressStyle};
            
            NSAttributedString* attrString = [[NSAttributedString alloc]
                                              initWithString:@"No Reports Available"
                                              attributes:attrs];
            
            noReportsLabel.attributedText = attrString;
            
            [noReportsLabel setBackgroundColor:[UIColor clearColor]];
            
            [self.tableView.superview addSubview:noReportsLabel];
                        
        } else {
            [noReportsLabel setHidden:YES];
        }
        viewLoadedAlreadyYN = NO;
    }
    
    searchDatePresent = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    sortButton = [[UIBarButtonItem alloc] initWithTitle:@"Sort"
                                                  style:UIBarButtonItemStylePlain
                                                 target:self action:@selector(sortResults)];
    
    [sortButton setTintColor:self.view.tintColor];
    
    NSArray *rightItems = [[NSArray alloc] initWithObjects:sortButton, nil];
    [[self navigationItem] setRightBarButtonItems:rightItems];
    
    dateButton = [[UIBarButtonItem alloc] initWithTitle:@"Date"
                                                  style:UIBarButtonItemStylePlain
                                                 target:self action:@selector(dateSearch)];
    
    [dateButton setTintColor:self.view.tintColor];
    
    
    NSArray *leftItems = [[NSArray alloc] initWithObjects:dateButton, nil];
    [[self navigationItem] setLeftBarButtonItems:leftItems];
    
    [searchbar setHidden:YES];

    self.navigationItem.leftBarButtonItem = nil ;
    
    if (includeSearchBar == YES) {
        [[UIBarButtonItem appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:self.view.tintColor];
        [searchbar setHidden:NO];
        searchbar.autocorrectionType = UITextAutocorrectionTypeNo;
        [searchbar setDelegate:self];
        [searchbar setPlaceholder:@"Search"];
        [searchbar setShowsCancelButton:YES animated:YES];
        [searchbar setBarTintColor:[UIColor colorWithRed:31/255.0f green:33/255.0f blue:36/255.0f alpha:1.0f]];
        [searchbar setTranslucent:YES];
        self.title = @"Search";
        self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects: dateButton,nil];
    }
    
    if (self.tableView.contentOffset.y <= 10) {
        [goToTop setHidden:YES];
    }
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    
    viewLoadedAlreadyYN = YES;
    
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewDidUnload
{
    self.fetchedResultsController = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - go to top method
- (IBAction)goToTop:(id)sender
{
    if (self.tableView.contentOffset.y >= 100) {
        
        [self.tableView setContentOffset:CGPointMake(0, self.navigationController.navigationBar.frame.origin.y + 50)
                                animated:YES];
    }
}

# pragma mark - change image color
- (UIImage *)imageWithColor:(UIColor *)color1 withImage:(UIImage *)img
{
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextClipToMask(context, rect, img.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - search methods

- (void)deleteSearchResults
{
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: sortButton, nil];
}

- (void)searchBarSearchReports:(UISearchBar *)searchBar
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"dateOfSighting" ascending:YES];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(reportHTML CONTAINS %@)", searchBar.text];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    
    titleName = [NSString stringWithFormat:@"Searched: %@", searchBar.text];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle error
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [tableView reloadData];
    [aivew stopAnimating];
    [searchBar resignFirstResponder];
    
    [self.tableView.superview makeToast:[NSString stringWithFormat:@"Showing %lu Reports", (unsigned long)self.fetchedResultsController.fetchedObjects.count] duration:2 position:@"center"];
    
    if (self.fetchedResultsController.fetchedObjects.count > 0) {
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: sortButton, flexibleItem ,clearButton, flexibleItem,nil];
    }

}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    aivew = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(searchBar.frame.size.width-130, 12, 22, 22)];
    [aivew setHidesWhenStopped:YES];
    [aivew setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [searchBar addSubview:aivew];
    [aivew startAnimating];
    [self performSelector:@selector(searchBarSearchReports:) withObject:searchBar afterDelay:0.5];

}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchDisplayController.searchBar.hidden = YES;
    [searchBar resignFirstResponder];
}

-(void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    controller.active = YES;
    
    [self.view addSubview:controller.searchBar];
    [self.view bringSubviewToFront:controller.searchBar];
}

#pragma mark - date search methods
- (void)dateSearch
{
    if (searchDatePresent == NO) {
        searchDatePresent = YES;
        
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"searchByDate" owner:self options:nil] objectAtIndex:0];
        [view setBackgroundColor:[UIColor clearColor]];
        [view setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7]];
        [[[[view subviews] objectAtIndex:0] layer] setCornerRadius:9.0f];
        [[[[view subviews] objectAtIndex:0] layer] setBorderColor:[UIColor whiteColor].CGColor];
        [[[[view subviews] objectAtIndex:0] layer] setBorderWidth:2.0f];
        
        NSArray *searchBarSubViews = [[view.subviews objectAtIndex:0] subviews];
        for (UIView *subView in searchBarSubViews) {
            if([subView conformsToProtocol:@protocol(UITextInputTraits)])
            {
                [(UITextField *)subView setDelegate:self];
                [(UITextField *)subView setReturnKeyType:UIReturnKeyDefault];
            }
        }
        
        [self showViewAnimated:self.searchByDate];
    } else {
        [self dismissViewAnimated:self.searchByDate];
        searchDatePresent = NO;
    }
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    
    [textField setText:[dateFormatter stringFromDate:[NSDate date]]];
    datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(datePickerValueChanged) forControlEvents:UIControlEventValueChanged];
    [textField setInputView:datePicker];
    currentTextField = textField;
    
}

- (void)datePickerValueChanged
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    currentTextField.text = [dateFormatter stringFromDate:datePicker.date];
}

- (IBAction)searchDate:(id)sender {
    
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterMediumStyle];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;
    NSDate *dateFrom = [dateFormatter dateFromString:self.fromDate.text];
    NSDate *dateTo = [dateFormatter dateFromString:self.toDate.text];
    
    NSTimeInterval distanceBetweenDates = [dateTo timeIntervalSinceDate:dateFrom];
    
    if (distanceBetweenDates < 0) {
        [self.searchByDate makeToast:@"From Date cannot be greater than To Date!" duration:3 position:@"Center"];
        self.fromDate.layer.borderColor=[[UIColor redColor]CGColor];
        self.fromDate.layer.borderWidth=1.0;
    } else if ([self.fromDate.text isEqualToString:@""] || [self.toDate.text isEqualToString:@""]) {
        [self.searchByDate makeToast:@"Please select a date for both fields" duration:3 position:@"Center"];
    } else {
        // Begin search
        searchDatePresent = NO;
        self.fetchedResultsController = nil;
        [self dismissViewAnimated:self.searchByDate];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"dateOfSighting" ascending:NO];
        NSPredicate *datePredicate = [NSPredicate predicateWithFormat: @"dateOfSighting >= %@ && dateOfSighting <= %@", dateFrom, dateTo];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:datePredicate];
        titleName = [NSString stringWithFormat:@"%@ to %@", [df stringFromDate:dateFrom], [df stringFromDate:dateTo]];

        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Handle error
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        [tableView reloadData];
        
        if (self.fetchedResultsController.fetchedObjects.count > 0) {
            UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: sortButton, flexibleItem ,clearButton, flexibleItem,nil];
        }
        
        [self.tableView.superview makeToast:[NSString stringWithFormat:@"Showing %lu Reports", (unsigned long)self.fetchedResultsController.fetchedObjects.count] duration:2 position:@"center"];
    }
    
}

- (IBAction)cancelDate:(id)sender {
    searchDatePresent = NO;
    [self dismissViewAnimated:self.searchByDate];
    
}

#pragma mark - show and hide view

- (void)showViewAnimated:(UIView *)view {
    [self.view.superview addSubview:view];
    
    [UIView transitionWithView:self.view.superview
                      duration:.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [self.view.superview addSubview:view];
                    }
                    completion:NULL];
}

- (void)dismissViewAnimated:(UIView *)view {
    [UIView transitionWithView:self.view.superview
                      duration:.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        [view removeFromSuperview];
                    }
                    completion:NULL];
}


@end
