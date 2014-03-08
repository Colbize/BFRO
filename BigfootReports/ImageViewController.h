//
//  ImageViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 12/17/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWebView+AFNetworking.h"
#import <MessageUI/MessageUI.h>

@interface ImageViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *forward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *back;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) NSURL *url;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;

- (IBAction)refresh:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)forward:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)goHome:(id)sender;

@end
