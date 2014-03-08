//
//  LicenseViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 2/14/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "LicenseViewController.h"
#import "ImageViewController.h"

@interface LicenseViewController ()

@end

@implementation LicenseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    UIColor * color = [UIColor colorWithRed:94/255.0f green:48/255.0f blue:125/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:color];
    
    self.licenseLabel.attributedText = [self makePrettyLabelWithString:@"Licenses"];
    // self.iconsButton = [self makePrettyLabelWithString:@"App Icons by icons8"];
    self.TWTSideMenuViewControllerLabel.attributedText = [self makePrettyLabelWithString:@"TWTSideMenuViewController"];
    self.TwitterLabel.attributedText = [self makePrettyLabelWithString:@"STTwitter"];
    self.afnetworkingLabel.attributedText = [self makePrettyLabelWithString:@"AFNetworking"];
    self.iRateLabel.attributedText = [self makePrettyLabelWithString:@"iRate"];
    self.MWFeedParserLabel.attributedText = [self makePrettyLabelWithString:@"MWFeedParser"];
    self.popoverLabel.attributedText = [self makePrettyLabelWithString:@"PopoverView"];
    self.TDBadgeLabel.attributedText = [self makePrettyLabelWithString:@"TDBadgeCell"];
    self.toastLabel.attributedText = [self makePrettyLabelWithString:@"Toast"];
    self.raptureXML.attributedText = [self makePrettyLabelWithString:@"RaptureXML"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController.navigationBar setTranslucent:NO];
}

- (NSAttributedString *)makePrettyLabelWithString:(NSString *)string
{
    NSAttributedString *attString = [[NSAttributedString alloc]
                                      initWithString:string
                                      attributes:@{ NSForegroundColorAttributeName : [UIColor darkGrayColor],
                                                    NSFontAttributeName : [UIFont fontWithName:@"Helvetica Neue" size:15],
                                                    NSTextEffectAttributeName : NSTextEffectLetterpressStyle}];
    return attString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)icons8:(id)sender {
    ImageViewController *website = [[ImageViewController alloc] init];
    website.url = [NSURL URLWithString:@"http://www.icons8.com"];
    [self.navigationController pushViewController:website animated:YES];
}
@end
