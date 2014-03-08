//
//  ReportsViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 12/16/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportsByLocation.h"
#import <GooglePlus/GooglePlus.h>
#import <MessageUI/MessageUI.h>
@class GPPSignInButton;


@interface ReportsViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate, GPPSignInDelegate, GPPShareDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *goToTop;
@property (weak, nonatomic) ReportsByLocation *reportInfo;
@property (retain, nonatomic) GPPSignInButton *signInButton;
@property bool containsImageYN;
@property bool countryUSAYN;
@property (retain, nonatomic) NSString *searchedString;

- (IBAction)goToTop:(id)sender;
- (void)goToOriginalLink;

@end
