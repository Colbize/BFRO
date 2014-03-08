//
//  ChooseReportLocationViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/29/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "ChooseReportLocationViewController.h"
#import "Location.h"
#import "USACountiesByLocation.h"
#import "CountiesViewController.h"
#import "EveryReportViewController.h"
#import "TDBadgedCell.h"
@class ReportsByLocation;

@interface ChooseReportLocationViewController ()
{
    NSString *country;
    NSPredicate *predicate;
}
@end

@implementation ChooseReportLocationViewController
@synthesize chooseLocation, fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)chooseLocation:(id)sender
{
    NSError *error;
    switch (chooseLocation.selectedSegmentIndex) {
        case 0:
        {
            country = @"USA";
            break;
        }
        case 1:
        {
            country = @"Canada";
            break;
        }
        case 2:
        {
            country = @"International";
            break;
        }
            
        default:
            break;
    }
    predicate = [NSPredicate predicateWithFormat:@"(country contains %@)", country];
    [[fetchedResultsController fetchRequest] setPredicate:predicate];
    
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Handle you error here
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDBadgedCell *cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                             reuseIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"UITableViewCell"];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(TDBadgedCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    Location *info = [fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:info.name];
    
    int reportsCount = 0;
    
    if ([country isEqualToString:@"USA"]) {
        NSArray *countys = [info.countyByLocation allObjects];
        for (USACountiesByLocation *county in countys) {
            reportsCount += county.reportsByCounty.count ;
        }
        cell.badgeString = [NSString stringWithFormat:@"%d", reportsCount];
    } else {
        cell.badgeString = [NSString stringWithFormat:@"%lu", (unsigned long)[[info.reportsByLocation allObjects] count]];
    }
    cell.badgeColor = self.view.tintColor;//[UIColor colorWithRed:0.792 green:0.197 blue:0.219 alpha:1.000];
    cell.badge.radius = 9;
    cell.badge.fontSize = 18;
    cell.badgeRightOffset = 10.f;

    
}

#pragma mark - Tableview methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedValue = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    if ([country isEqualToString:@"USA"]) {
        
        CountiesViewController *cvc = [[CountiesViewController alloc] initWithStateName:selectedValue];
        [self.navigationController pushViewController:cvc animated:YES];
        
    } else {
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"dateOfSighting" ascending:NO];
        NSPredicate *predicateLoc =
        [NSPredicate predicateWithFormat: @"(reportsByLocation.name = %@)", selectedValue];
        
        [fetchRequest setPredicate:predicateLoc];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setEntity:entity];
        
        EveryReportViewController *rvc = [[EveryReportViewController alloc] initwithFetchRequest:fetchRequest
                                                                                       titleName:[NSString stringWithFormat:@"%@ - %@", selectedValue, country]];
        [self.navigationController pushViewController:rvc animated:YES];
    }
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    
    NSString *string = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    
    return string;
}

# pragma mark - NSFetchedResultsController methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:YES];    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                  managedObjectContext:[[BFROStore sharedStore] context]
                                                                                                    sectionNameKeyPath:nil
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
    
    UITableView *tableView = self.tableView;
    
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

#pragma mark - view load methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    country = @"USA";
    predicate = [NSPredicate predicateWithFormat:@"(country contains %@)", country];
    NSError *error;
    if (![[self fetchedResultsController] performFetch:&error]) {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    [self.tableView reloadData];

    
    // Do any additional setup after loading the view from its nib.
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"Browse Reports DB";

}

- (void)viewDidUnload
{
    self.fetchedResultsController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
