//
//  AltFrontViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 2/3/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AltFrontViewController : UIViewController
- (IBAction)recentReports:(id)sender;
- (IBAction)browseReports:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *recentReports;
@property (weak, nonatomic) IBOutlet UIButton *browseReports;
@property (weak, nonatomic) IBOutlet UIButton *submitAReport;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
- (IBAction)submitReport:(id)sender;

@end
