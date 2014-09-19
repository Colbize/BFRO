//
//  SettingsViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 12/19/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *designedBy;
@property (weak, nonatomic) IBOutlet UIButton *signOutButton;
@property (weak, nonatomic) IBOutlet UILabel *versionNumberInfo;
- (IBAction)goToDigitalWebsite:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *copyright;
@end
