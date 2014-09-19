//
//  SettingsViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 12/19/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "SettingsViewController.h"
#import "LicenseViewController.h"
#import "ImageViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                             reuseIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:@"cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if (indexPath.row == 0) {
        [cell.textLabel setText:@"Rate App"];
    } else if (indexPath.row == 1) {
        [cell.textLabel setText:@"Contact Us"];
    } else if (indexPath.row == 2) {
        [cell.textLabel setText:@"Licenses"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"Ratings are extremely apperciated! If you have any issues with the app please contact us first! Thank you." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertview show];
        [alertview setTag:1];
    } else if (indexPath.row == 1) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Contact Us Via:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Phone", @"E-Mail", nil];
        [alertview show];
        [alertview setTag:2];
    } else if (indexPath.row == 2) {
        LicenseViewController *license = [[LicenseViewController alloc] init];
        [self.navigationController pushViewController:license animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1) {
        NSString* url = [NSString stringWithFormat: @"https://itunes.apple.com/us/app/bfro/id826168573?ls=1&mt=8"];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    } else if (alertView.tag  == 2) {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Phone"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://4086342376"]];
        } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"E-Mail"]) {
            UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"If you would like to submit a sightings report, please use the \"Submit a Report\" Form in the Reports Menu. For all other inquires, please email us." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertview show];
            [alertview setTag:3];
        }
    } else if (alertView.tag == 3){
        MFMailComposeViewController *messageVC = [[MFMailComposeViewController alloc] init];
        [messageVC setMailComposeDelegate:self];
        if ([MFMailComposeViewController canSendMail]) {
            [messageVC setToRecipients:[NSArray arrayWithObjects:@"ContactUs@BFRO.NET", nil]];
            [self presentViewController:messageVC animated:YES completion:nil];
        }
    }
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
            id value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"Center" : [NSValue valueWithCGPoint:CGPointMake(200, 300)];
            [self.view makeToast:@"Sent!" duration:1.5 position:value];
        }
            break;
        case MFMailComposeResultFailed:
        {
            id value = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? @"Center" : [NSValue valueWithCGPoint:CGPointMake(200, 300)];
            [self.view makeToast:@"Unable to Send at This Time." duration:1.5 position:value];
            
        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark - view load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // OPEN DRAWER BUTTON
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:Nil
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(revealMenu)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"]];
    [menuButton setTintColor:[UIColor whiteColor]];
    
    [[self navigationItem] setLeftBarButtonItem:menuButton];
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    NSAttributedString *appInfo = [[NSAttributedString alloc]
                                   initWithString:[NSString stringWithFormat:@"B.F.R.O Version %@ Build %@", version, build]
                                   attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                 NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:19],
                                                 NSTextEffectAttributeName : NSTextEffectLetterpressStyle}];
    
    self.versionNumberInfo.attributedText = appInfo;
    
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"Settings";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    NSAttributedString *designedBy = [[NSAttributedString alloc]
                                      initWithString:@"Designed and Developed By Colby Reineke."
                                      attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                    NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:13.5],
                                                    NSTextEffectAttributeName : NSTextEffectLetterpressStyle}];
    
    self.designedBy.attributedText = designedBy;
    
    NSAttributedString *copyright = [[NSAttributedString alloc]
                                      initWithString:@"Copyright BFRO © 2015"
                                      attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                    NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:15],
                                                    NSTextEffectAttributeName : NSTextEffectLetterpressStyle}];
    
    self.copyright.attributedText = copyright;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self.tabBarController.tabBar setHidden:YES];
    UIColor * color = [UIColor colorWithRed:94/255.0f green:48/255.0f blue:125/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:color];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
}

- (void)revealMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
