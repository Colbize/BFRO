//
//  CountiesViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 8/27/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "CountiesViewController.h"
#import "USACountiesByLocation.h"
#import "EveryReportViewController.h"
#import "TDBadgedCell.h"

@interface CountiesViewController ()

@end

@implementation CountiesViewController
@synthesize fetchedResultsController;

- (id)initWithStateName:(NSString *)sn
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        
        stateName = sn;
    }
    return self;
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
    USACountiesByLocation *info = [fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:info.name];
    
    cell.badgeString = [NSString stringWithFormat:@"%lu", info.reportsByCounty.count];
    cell.badgeColor = self.view.tintColor;
    cell.badge.radius = 9;
    cell.badge.fontSize = 18;
    cell.badgeRightOffset = 10.f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     NSString *selectedValue = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"dateOfSighting" ascending:NO];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat: @"(usaCountyReports.name = %@) AND (usaCountyReports.location.name = %@)", selectedValue, stateName];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    NSString *titleName = [NSString stringWithFormat:@"USA - %@ - %@", selectedValue, stateName];
    EveryReportViewController *rvc = [[EveryReportViewController alloc] initwithFetchRequest:fetchRequest titleName:titleName];
    [self.navigationController pushViewController:rvc animated:YES];
}

# pragma mark - NSFetchedResultsController methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"USACountiesByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"location.name = %@" , stateName];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
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
    
    self.title = @"Select County";
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
}

- (void)viewWillAppear:(BOOL)animated
{
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
