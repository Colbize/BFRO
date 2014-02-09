//
//  LocationViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 8/27/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "LocationsViewController.h"
#import "CountiesViewController.h"
#import "States.h"

@interface LocationsViewController ()

@end

@implementation LocationsViewController
@synthesize fetchedResultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFetchResults:(NSString *)pred USAYN:(BOOL *)YN
{
    if (self) {
        predicateSearch = pred;
        USAYN = YN;
    }
    return self;
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
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"UITableViewCell"];
    }    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    States *info = [fetchedResultsController objectAtIndexPath:indexPath];
    [cell.textLabel setText:info.name];
    
}

//- (void)tableView:(UITableView *)tableView
//  willDisplayCell:(UITableViewCell *)cell
//forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_background"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_selected_background"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
//    
//    cell.textLabel.textColor = [UIColor colorWithRed:190.0f/255.0f green:197.0f/255.0f blue:212.0f/255.0f alpha:1.0f];
//    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
//    cell.textLabel.shadowColor = [UIColor colorWithRed:33.0f/255.0f green:38.0f/255.0f blue:49.0f/255.0f alpha:1.0f];
//    cell.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0f];
//    
//    cell.imageView.clipsToBounds = YES;
//    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    
//    UIImageView *separator = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_selected_background"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
//    
//    [cell.contentView addSubview: separator];
//    
//}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedValue = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;

    if (USAYN) {
        
        CountiesViewController *cvc = [[CountiesViewController alloc] initWithStateName:selectedValue];
        [self.navigationController pushViewController:cvc animated:YES];
    
    } else {
        
        [self.navigationController popToRootViewControllerAnimated:NO];

        [tabbed.iivdc closeLeftViewBouncing:^(IIViewDeckController *controller) {
            tabbed.iivdc.leftSize = 50;
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"Reports" inManagedObjectContext:[[BFROStore sharedStore] context]];
            NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                      initWithKey:@"date" ascending:NO];
            NSPredicate *predicate =
            [NSPredicate predicateWithFormat: @"(states.name = %@)", selectedValue];
            
            [fetchRequest setPredicate:predicate];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            [fetchRequest setEntity:entity];
            
            AllReportsViewController *rvc = [[AllReportsViewController alloc] initwithFetchRequest:fetchRequest titleName:selectedValue];
            UINavigationController *reportNav = [[UINavigationController alloc] initWithRootViewController:rvc];
            
            [tabbed.iivdc setCenterController:reportNav];
            
        }];

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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"States" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"name" ascending:YES];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(link contains %@)", predicateSearch];
    
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
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewWillAppear:(BOOL)animated
{
    tabbed.iivdc.leftSize = 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
