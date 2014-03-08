//
//  SettingsViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 12/19/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "SettingsViewController.h"
#import <Social/Social.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "LicenseViewController.h"
#import "ImageViewController.h"
#import "Instabug/Instabug.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
static NSString * const kClientId = @"134355214729-qdlaclmspla1nqs69440oekaleu6plm3.apps.googleusercontent.com";
@synthesize signInButton;

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
    return 5;
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
        [cell.textLabel setText:@"Send Feedback"];
    } else if (indexPath.row == 1) {
        [cell.textLabel setText:@"Submit a Bug"];
    } else if (indexPath.row == 2) {
        [cell.textLabel setText:@"Rate App"];
    } else if (indexPath.row == 3) {
        [cell.textLabel setText:@"Contact Us"];
    } else if (indexPath.row == 4) {
        [cell.textLabel setText:@"Licenses"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        [Instabug setButtonsColor:[UIColor colorWithRed:(58/255.0) green:(69/255.0) blue:(80/255.0) alpha:1.0]];
        [Instabug setButtonsFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
        [Instabug setHeaderColor:[UIColor colorWithRed:(130/255.0) green:(98/255.0) blue:(145/255.0) alpha:1.0]];
        [Instabug setHeaderFontColor:[UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:1.0]];
        [Instabug setTextBackgroundColor:[UIColor colorWithRed:(249/255.0) green:(249/255.0) blue:(249/255.0) alpha:1.0]];
        [Instabug setTextFontColor:[UIColor colorWithRed:(82/255.0) green:(83/255.0) blue:(83/255.0) alpha:1.0]];
        [Instabug ShowFeedbackFormWithScreenshot:(BOOL)NO];

    } else if (indexPath.row == 1) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"How to Submit a Bug:" message:@"To submit a bug, go to where the bug is occuring within the app and shake the device for 2 seconds.  The app will automatically take a screenshot and you may annotate and/or add text along with the bug submission. Thank you for your support!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertview show];
        [alertview setTag:0];
    } else if (indexPath.row == 2) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:nil message:@"Ratings are extremely apperciated! If you have any issues with the app please contact us first! Thank you." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertview show];
        [alertview setTag:1];
    } else if (indexPath.row == 3) {
        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"Contact Us Via:" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Phone", @"E-Mail", nil];
        [alertview show];
        [alertview setTag:2];
    } else if (indexPath.row == 4) {
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
        NSString* url = [NSString stringWithFormat: @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=680262157"];
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
                                      initWithString:@"Designed and Developed By:"
                                      attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                    NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:13.5],
                                                    NSTextEffectAttributeName : NSTextEffectLetterpressStyle}];
    
    self.designedBy.attributedText = designedBy;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    [self.tabBarController.tabBar setHidden:YES];
    UIColor * color = [UIColor colorWithRed:94/255.0f green:48/255.0f blue:125/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:color];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    
    if ([[GPPSignIn sharedInstance] authentication]) {
        [self.signOutButton setTitle:@"SignOut of Google+" forState:UIControlStateNormal];
        UIColor * color = [UIColor colorWithRed:255/255.0f green:93/255.0f blue:86/255.0f alpha:1.0f];
        [self.signOutButton setBackgroundColor:color];

    } else {
        [self.signOutButton setTitle:@"Sign Into Google+" forState:UIControlStateNormal];
        UIColor * color = [UIColor colorWithRed:124/255.0f green:153/255.0f blue:241/255.0f alpha:1.0f];
        [self.signOutButton setBackgroundColor:color];
    }
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

- (IBAction)signOutGoogle:(id)sender {
    if ([[GPPSignIn sharedInstance] authentication]) {
        [self.view makeToast:@"Signed Out of Google+" duration:1.5 position:@"center"];
        [[GPPSignIn sharedInstance] signOut];
        
        [self.signOutButton setTitle:@"Sign Into Google+" forState:UIControlStateNormal];
        UIColor * color = [UIColor colorWithRed:124/255.0f green:153/255.0f blue:241/255.0f alpha:1.0f];
        [self.signOutButton setBackgroundColor:color];
    } else {
        // Perform other actions here
        GPPSignIn *signIn = [GPPSignIn sharedInstance];
        signIn.shouldFetchGooglePlusUser = YES;
        
        // You previously set kClientId in the "Initialize the Google+ client" step]
        signIn.clientID = kClientId;
        
        signIn.scopes = @[kGTLAuthScopePlusLogin];
        // Optional: declare signIn.actions, see "app activities"
        signIn.delegate = self;
        [signIn authenticate];
    }
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    if (!error) {
        [self.view makeToast:@"Signed Into Google+, You may now share reports using Google+" duration:3 position:@"center"];

        [self.signOutButton setTitle:@"SignOut of Google+" forState:UIControlStateNormal];
        UIColor * color = [UIColor colorWithRed:255/255.0f green:93/255.0f blue:86/255.0f alpha:1.0f];
        [self.signOutButton setBackgroundColor:color];
    }
}
- (IBAction)goToDigitalWebsite:(id)sender {
    ImageViewController *website = [[ImageViewController alloc] init];
    website.url = [NSURL URLWithString:@"http://www.digitalchild.net"];
    [self.navigationController pushViewController:website animated:YES];
}
@end
