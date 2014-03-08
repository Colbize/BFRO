//
//  bfroExpeditionsViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/23/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface bfroExpeditionsViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) UIWebView *contentHolderView;

@end
