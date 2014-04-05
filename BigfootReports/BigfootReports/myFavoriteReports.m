//
//  myFavoriteReports.m
//  BigfootReports
//
//  Created by Colby Reineke on 8/31/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "myFavoriteReports.h"
#import "ReportsViewController.h"
#import "ReportsByLocation.h"
#import <QuartzCore/QuartzCore.h>

@interface myFavoriteReports ()
{
    NSArray *favDic;
    NSMutableDictionary *favoritesDic;
    ReportsByLocation *reportsInfo;
    UIView *hudView;
    UIActivityIndicatorView *aiView;
    UILabel *noReportsLabel;
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
        
    hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 170, 170)];
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    hudView.clipsToBounds = YES;
    hudView.layer.cornerRadius = 10.0;
    
    aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiView.frame = CGRectMake(65, 40, aiView.bounds.size.width, aiView.bounds.size.height);
    [hudView addSubview:aiView];
    [hudView setCenter:self.view.center];
    [aiView startAnimating];
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.text = @"Loading Report...";
    [hudView addSubview:captionLabel];
    [self.tableView.superview addSubview:hudView];
    
    double delayInSeconds = .2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

        ReportsViewController *rvc = [[ReportsViewController alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"ReportsByLocation"
                                       inManagedObjectContext:[[BFROStore sharedStore] context]];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(reportID = %@)", [NSNumber numberWithInteger:[[tableView cellForRowAtIndexPath:indexPath].textLabel.text substringFromIndex:12].integerValue]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        reportsInfo = [[[[BFROStore sharedStore] context] executeFetchRequest:fetchRequest error:&error] lastObject];
        
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to load report." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            NSLog(@"%@", error);
        } else {
            [rvc setReportInfo:reportsInfo];
        
            [self.navigationController pushViewController:rvc animated:YES];
        }

        [aiView stopAnimating];
        [hudView removeFromSuperview];
        
    });
}

#pragma mark - view load methods
- (void)viewDidLoad
{
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [super viewDidLoad];
    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.navigationItem setRightBarButtonItem:[self editButtonItem]];
    
    // OPEN DRAWER BUTTON
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:Nil
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(revealMenu)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"]];
    [menuButton setTintColor:[UIColor whiteColor]];
    
    [[self navigationItem] setLeftBarButtonItem:menuButton];

}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:YES];

    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    [[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
    favoritesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] mutableCopy];
    favDic = favoritesDic.allKeys;
    [self.tableView reloadData];
    
    self.title = @"My Favorite Reports";
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIColor * bcolor = [UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1.0f];
    [self.tableView setBackgroundColor:bcolor];

    
    if (favDic.count < 1) {
        if (!noReportsLabel)
            noReportsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            UIFont* font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            
            UIColor* textColor = [UIColor lightGrayColor];
            
            NSDictionary *attrs = @{ NSForegroundColorAttributeName : textColor,
                                     NSFontAttributeName : font,
                                     NSTextEffectAttributeName : NSTextEffectLetterpressStyle};
            
            NSAttributedString* attrString = [[NSAttributedString alloc]
                                              initWithString:@"No Reports Added"
                                              attributes:attrs];
            
            noReportsLabel.attributedText = attrString;
            
            [noReportsLabel setBackgroundColor:[UIColor clearColor]];
            
            [self.view.superview addSubview:noReportsLabel];
            [noReportsLabel setCenter:CGPointMake(self.view.frame.size.width/2 + 25, self.view.frame.size.height/2)];
    }

}

# pragma mark - reveal menu
- (void)revealMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

# pragma mark - rotate view
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [noReportsLabel setCenter:CGPointMake(self.view.frame.size.width/2 + 25, self.view.frame.size.height/2)];
}
@end
