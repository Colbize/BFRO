//
//  WhatisBigfootWebViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/23/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PopoverView.h"

@interface WebViewController : UIViewController <UIWebViewDelegate, MKMapViewDelegate, PopoverViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString *htmlString;
@property (strong, nonatomic) NSString *urlString;

@end
