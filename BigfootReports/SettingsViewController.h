//
//  SettingsViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 12/19/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <GooglePlus/GooglePlus.h>
@class GPPSignInButton;

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, GPPSignInDelegate, GPPShareDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *designedBy;
- (IBAction)signOutGoogle:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (retain, nonatomic) GPPSignInButton *signInButton;
@property (weak, nonatomic) IBOutlet UILabel *versionNumberInfo;
- (IBAction)goToDigitalWebsite:(id)sender;

@end
