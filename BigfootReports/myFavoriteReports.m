//
//  myFavoriteReports.m
//  BigfootReports
//
//  Created by Colby Reineke on 8/31/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "myFavoriteReports.h"
#import "ReportViewController.h"

@interface myFavoriteReports ()
{
    NSArray *favDic;
    NSMutableDictionary *favoritesDic;
}
@end

@implementation myFavoriteReports

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return favDic.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                                   reuseIdentifier:@"UITableViewCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    NSString *rowID = [NSString stringWithFormat:@"Report ID : %@", [favDic objectAtIndex:indexPath.row]];
    [cell.textLabel setText:rowID];
    [cell.detailTextLabel setText:[favoritesDic objectForKey:[favDic objectAtIndex:indexPath.row]]];
    
    return cell;
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *selectedValue = [self tableView:tableView cellForRowAtIndexPath:indexPath].textLabel.text;
        
        [favoritesDic removeObjectForKey:[selectedValue substringFromIndex:12]];
        favDic = favoritesDic.allKeys;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [[NSUserDefaults standardUserDefaults] setObject:favoritesDic forKey:@"favoritesDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    [self.tableView reloadData];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportViewController *rvc = [[ReportViewController alloc] init];
    [rvc setReportID:[NSNumber numberWithInteger:[[tableView cellForRowAtIndexPath:indexPath].textLabel.text substringFromIndex:12].integerValue]];
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark - view load methods
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    UIColor * color = [UIColor colorWithRed:28/255.0f green:27/255.0f blue:26/255.0f alpha:1.0f];
    self.navigationController.navigationBar.tintColor = color;
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cell_background"] stretchableImageWithLeftCapWidth:0.0 topCapHeight:5.0]];
    
    favoritesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] mutableCopy];
    favDic = favoritesDic.allKeys;
        
    [self.navigationItem setRightBarButtonItem:[self editButtonItem]];
}

- (void)viewWillAppear:(BOOL)animated
{
    favoritesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] mutableCopy];
    favDic = favoritesDic.allKeys;
    [self.tableView reloadData];
    tabbed.iivdc.leftSize = 0;
}


@end
