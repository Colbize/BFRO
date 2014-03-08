//
//  LicenseViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 2/14/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LicenseViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *licenseLabel;
@property (weak, nonatomic) IBOutlet UILabel *iconsLabel;
@property (weak, nonatomic) IBOutlet UIButton *iconsButton;
@property (weak, nonatomic) IBOutlet UILabel *TWTSideMenuViewControllerLabel;
@property (weak, nonatomic) IBOutlet UILabel *TwitterLabel;
@property (weak, nonatomic) IBOutlet UILabel *afnetworkingLabel;
@property (weak, nonatomic) IBOutlet UILabel *iRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *MWFeedParserLabel;
@property (weak, nonatomic) IBOutlet UILabel *popoverLabel;
@property (weak, nonatomic) IBOutlet UILabel *TDBadgeLabel;
@property (weak, nonatomic) IBOutlet UILabel *toastLabel;

@property (weak, nonatomic) IBOutlet UILabel *raptureXML;
- (IBAction)icons8:(id)sender;

@end
