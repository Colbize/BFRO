//
//  WhatIsBigfootViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/22/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhatIsBigfootViewController : UIViewController
- (IBAction)Anatomy:(id)sender;
- (IBAction)Physiology:(id)sender;
- (IBAction)Behavior:(id)sender;
- (IBAction)Literature:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
