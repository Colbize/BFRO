//
//  SideDeckViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/30/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "SideDeckViewController.h"
#import "SettingsViewController.h"
#import "AltFrontViewController.h"
#import "myFavoriteReports.h"
#import "EveryReportViewController.h"
#import "UpdateReportsDB.h"

@interface SideDeckViewController ()
{
    UIView *hudView;
    UIActivityIndicatorView *aiView;
    NSMutableDictionary *recentlyAdded;
    BOOL updateBeginYN;
    UILabel *captionLabel;
}
@end

@implementation SideDeckViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedUpdateFromReportsDBNoty:)
                                                     name:@"receivedUpdateFromReportsDBNoty"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receivedUpdateFromReportsDBNoty:)
                                                     name:@"sendToastNoty"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    updateBeginYN = NO;
    recentlyAdded = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animate
{
    [self.sideMenuViewController setDelegate:self];
    
    [self.tableView reloadData];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 70 : 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    else if (section == 1) return 1;
    else if (section == 2) return 2;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TDBadgedCell *cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                             reuseIdentifier:@"TDBadgedCell"];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"TDBadgedCell"];
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            [cell.textLabel setText:@"Update Reports Database"];
        }
    } else if (indexPath.section == 1) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"news"]];
        imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
        [[cell imageView] setImage:imageView.image];
        [cell.textLabel setText:@"Reports Menu"];
    } else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hearts"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            [cell.textLabel setText:@"My Favorite Reports"];
            cell.badgeString = [NSString stringWithFormat:@"%lu",(unsigned long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] count]];
            cell.badgeColor = [UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f];
            cell.badge.radius = 6;
            cell.badge.fontSize = 18;
            cell.badgeTextColor = [UIColor whiteColor];
            cell.badgeRightOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50.f :450.f;
        } else if (indexPath.row == 1) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"internal"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            cell.badgeString = [NSString stringWithFormat:@"%lu",(unsigned long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] count]];
            cell.badgeColor = self.view.tintColor;
            cell.badge.radius = 6;
            cell.badge.fontSize = 18;
            cell.badgeTextColor = [UIColor whiteColor];
            cell.badgeRightOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50.f : 450.f;
            [cell.textLabel setText:@"New Reports"];
        }
    } else {
    
        if (indexPath.row == 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"settings"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            [cell.textLabel setText:@"Settings"];
        }
    }
    [cell.imageView setTintColor:[UIColor whiteColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if (updateBeginYN != YES) {
                updateBeginYN = YES;
                [self checking];
                [self performSelector:@selector(updatingReports) withObject:Nil afterDelay:1.0];
            }
        }
    } else if (indexPath.section == 1) {
            AltFrontViewController *fvc = [[AltFrontViewController alloc] init];
            UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:fvc];
            [self.sideMenuViewController setMainViewController:controller animated:YES closeMenu:YES];
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            myFavoriteReports *mfr = [[myFavoriteReports alloc] initWithStyle:UITableViewStylePlain];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:mfr];
            [self.sideMenuViewController setMainViewController:nav animated:YES closeMenu:YES];
        } else {
            recentlyAdded = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] mutableCopy];
            
            if (!recentlyAdded.count > 0) {
                id value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"Center" : [NSValue valueWithCGPoint:CGPointMake(200, 300)];
                
                [self.tableView.superview makeToast:@"No New Reports Available" duration:2 position:value];
                return;
            }
            [self loading];
            [self performSelector:@selector(showRecentlyAdded) withObject:nil afterDelay:0.0];
        }
    } else {
        SettingsViewController *svc = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
        UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:svc];
        [self.sideMenuViewController setMainViewController:controller animated:YES closeMenu:YES];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

# pragma mark - show recently added
- (void)showRecentlyAdded
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"witnessSubmitted" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(reportID IN %@)", recentlyAdded.allKeys];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    NSString *titleString = [NSString stringWithFormat:@"New Reports"];
    EveryReportViewController *rvc = [[EveryReportViewController alloc] initwithFetchRequest:fetchRequest titleName:titleString];
    [rvc setRecentlyAddedSection:YES];
    [self stopLoading];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rvc];
    [self.sideMenuViewController setMainViewController:nav animated:YES closeMenu:YES];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAddedNote"]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"RecentlyAddedNote"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"NOTE!"
                                                          message:@"A report will be automatically removed from the \"Recently Added\" section once the report has been opened/read."
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [message show];
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


#pragma mark - loading view methods
- (void)loading
{
    hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 180, 140)];
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    hudView.clipsToBounds = YES;
    hudView.layer.cornerRadius = 10.0;
    
    aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiView.frame = CGRectMake(69, 40, aiView.bounds.size.width, aiView.bounds.size.height);
    [hudView addSubview:aiView];
    [hudView setCenter:self.view.center];
    [aiView startAnimating];
    
    captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 140, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.text = @"Loading Reports...";
    [hudView addSubview:captionLabel];
    [self.view.superview addSubview:hudView];

    
}

- (void)checking
{
    hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 180, 160)];
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    hudView.clipsToBounds = YES;
    hudView.layer.cornerRadius = 10.0;
    
    aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiView.frame = CGRectMake(69, 40, aiView.bounds.size.width, aiView.bounds.size.height);
    [hudView addSubview:aiView];
    [hudView setCenter:self.view.center];
    [aiView startAnimating];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(requestToCancel)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    button.frame = CGRectMake(20, 105, 140, 60);
    //[button setBackgroundColor:[UIColor whiteColor]];
    [hudView addSubview:button];
    
    captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 140, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.text = @"Connecting to DB...";
    [hudView addSubview:captionLabel];
    [self.view.superview addSubview:hudView];
    hudView.center = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? CGPointMake(self.view.superview.frame.size.width/2, self.view.superview.frame.size.height/2) : CGPointMake(self.view.superview.frame.size.width/2 - 200, self.view.superview.frame.size.height/2 - 200);
    
}

- (void)stopLoading
{
    [aiView stopAnimating];
    [hudView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
}

#pragma mark - updatingReports

- (void)updatingReports
{
    UpdateReportsDB *update = [[UpdateReportsDB alloc] init];
    [update connectToSite];
}

- (void)receivedUpdateFromReportsDBNoty:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"receivedUpdateFromReportsDBNoty"]) {
        captionLabel.text = (NSString*)[notification object];
    } else if ([[notification name] isEqualToString:@"sendToastNoty"]) {
         updateBeginYN = NO;
        id value = UI_USER_INTERFACE_IDIOM() ==
        UIUserInterfaceIdiomPhone ? [NSValue valueWithCGPoint:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 150)] : [NSValue valueWithCGPoint:CGPointMake(200, 300)];
        [hudView removeFromSuperview];
        [self.view makeToast:(NSString*)[notification object] duration:2.0 position:value];
        [self.tableView reloadData];
    }
}

#pragma mark - side menu delegates
- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    [self.tableView reloadData];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setNeedsStatusBarAppearanceUpdate];
    
}

#pragma mark - preferredStatusBarStyle
-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - requestToCancel
- (void)requestToCancel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestToCancel"
                                                        object:@"cancel"];

}

#pragma mark - dealloc

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"receivedUpdateFromReportsDBNoty"  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"sendToastNoty"  object:nil];
}
@end
