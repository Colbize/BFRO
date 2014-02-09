//
//  SideDeckViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/30/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "SideDeckViewController.h"
#import "AppInfoViewController.h"
#import "AltFrontViewController.h"
#import "UIDevice-Hardware.h"   
#import "myFavoriteReports.h"
#import "EveryReportViewController.h"

@interface SideDeckViewController ()
{
    UIView *hudView;
    UIActivityIndicatorView *aiView;
    NSMutableDictionary *recentlyAdded;
}
@end

@implementation SideDeckViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

//

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewWillAppear:(BOOL)animate
{
    [self.sideMenuViewController setDelegate:self];
 //   [self.tableView setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
    
    [[self.navigationController navigationBar] setBarTintColor:[UIColor viewFlipsideBackgroundColor]];
    
//    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                    [UIColor whiteColor],NSForegroundColorAttributeName,
//                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
//    
//    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return 1;
    else if (section == 1) return 1;
    else if (section == 2) return 2;
    else return 3;
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
            cell.badgeRightOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50.f : 400.f;
        } else if (indexPath.row == 1) {
            cell.badgeString = [NSString stringWithFormat:@"%lu",(unsigned long)[[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] count]];
            cell.badgeColor = self.view.tintColor;//[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f];
            cell.badge.radius = 6;
            cell.badge.fontSize = 18;
            cell.badgeTextColor = [UIColor whiteColor];
            cell.badgeRightOffset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 50.f : 400.f;
            [cell.textLabel setText:@"Recently Added Reports"];
        }
    } else {
    
        if (indexPath.row == 0) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"info"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            [cell.textLabel setText:@"App Info"];
        } else if (indexPath.row == 1) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"topic"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            [cell.textLabel setText:@"Feedback"];
        } else if (indexPath.row == 2) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bug"]];
            imageView.image = [self imageWithColor:[UIColor whiteColor] withImage:imageView.image];
            [[cell imageView] setImage:imageView.image];
            [cell.textLabel setText:@"Submit a Bug"];
        }
    }
    [cell.imageView setTintColor:[UIColor whiteColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self findNewReports];
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
                [self.tableView.superview makeToast:@"No New Reports Available" duration:2 position:@"center"];
                return;
            }
            [self loading];
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
            NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                      initWithKey:@"dateOfSighting" ascending:YES];
            NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(ANY reportID IN %@)", recentlyAdded.allKeys];
            
            [fetchRequest setPredicate:predicate];
            [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
            [fetchRequest setEntity:entity];
            NSString *titleString = [NSString stringWithFormat:@"Recently Added Reports"];
            EveryReportViewController *rvc = [[EveryReportViewController alloc] initwithFetchRequest:fetchRequest titleName:titleString];
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

    } else {
    
        switch (indexPath.row) {
            case 0: {
                AppInfoViewController *aivc = [[AppInfoViewController alloc] initWithNibName:nil bundle:nil];
                UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:aivc];
                [self.sideMenuViewController setMainViewController:controller animated:YES closeMenu:YES];
                break;
            }
            case 1: {
                MFMailComposeViewController *messageVC = [[MFMailComposeViewController alloc] init];
                [messageVC setMailComposeDelegate:self];
                if ([MFMailComposeViewController canSendMail]) {
                    [messageVC setToRecipients:[NSArray arrayWithObjects:@"BeyondTheCheese@gmail.com", nil]];
                    [messageVC setSubject:@"BFRO App Reports Feedback"];

                     NSString *messageBody = NSLocalizedString(([NSString stringWithFormat:@"<br/><br/><br/> App Version: %@ <br/> Device Model: %@ <br/>  OS Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] systemVersion]]), nil);
                    [messageVC setMessageBody:messageBody isHTML:YES];
                    [self presentViewController:messageVC animated:YES completion:nil];
                }

                break;
            }
            case 2: {
                MFMailComposeViewController *messageVC = [[MFMailComposeViewController alloc] init];
                [messageVC setMailComposeDelegate:self];
                if ([MFMailComposeViewController canSendMail]) {
                    [messageVC setToRecipients:[NSArray arrayWithObjects:@"BeyondTheCheese@gmail.com", nil]];
                    [messageVC setSubject:@"BFRO App Reporting a Bug"];
                    
                    NSString *messageBody = NSLocalizedString(([NSString stringWithFormat:@"<br/><br/><br/> App Version: %@ <br/> Device Model: %@ <br/>  OS Version: %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] systemVersion]]), nil);
                    [messageVC setMessageBody:messageBody isHTML:YES];
                    [self presentViewController:messageVC animated:YES completion:nil];
                }

                break;
            }
            default:
                break;
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


#pragma mark - Message delegate methods
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSent:
        {
            [self.view makeToast:@"Sent!" duration:1.5 position:@"center"];
        }
            break;
        case MFMailComposeResultFailed:
        {
            [self.view makeToast:@"Unable to Send!" duration:1.5 position:@"center"];
            
        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
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
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 140, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.text = @"Loading Report..";
    [hudView addSubview:captionLabel];
    [self.view.superview addSubview:hudView];

    
}

- (void)checking
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
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 140, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.text = @"Updating Reports DB..";
    [hudView addSubview:captionLabel];
    [self.view.superview addSubview:hudView];
    
}

- (void)stopLoading
{
    [aiView stopAnimating];
    [hudView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
}


#pragma mark - Find new reports method

- (void)findNewReports
{
    [self checking];
    [self performSelector:@selector(updatingReports) withObject:Nil afterDelay:5];
}

- (void)updatingReports
{
    [self stopLoading];
    [self.tableView.superview makeToast:@"No New Reports" duration:2 position:@"center"];
}

#pragma mark - side menu delegats
- (void)sideMenuViewControllerWillOpenMenu:(TWTSideMenuViewController *)sideMenuViewController
{
    [self.tableView reloadData];
}

@end
