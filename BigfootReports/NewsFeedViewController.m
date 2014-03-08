//
//  NewsFeedViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/13/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "NewsFeedViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "NewsFeedCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageViewController.h"
#import "STTwitterAPI.h"
#import <UIImageView+AFNetworking.h>
#import <NSString+HTML.h>

@interface NewsFeedViewController ()
{
    NSArray *timelineInfo;
    UIView *hudView;
    float cellHeight;
}
@property (nonatomic) ACAccountStore *accountStore;
@end

@implementation NewsFeedViewController
@synthesize tableView;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        timelineInfo = [[NSMutableArray alloc] init];
    }
    return self;
}


#pragma mark - view load
- (void)viewWillLayoutSubviews
{
    UIColor * color = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    [[self.navigationController navigationBar] setBarTintColor:color];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTranslucent:NO];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
    
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    UIColor * color = [UIColor colorWithRed:85/255.0f green:172/255.0f blue:238/255.0f alpha:1.0f];
    [[self.navigationController navigationBar] setBarTintColor:color];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *timelineData = [defaults objectForKey:@"timelineInfo"];
    
    if (![defaults objectForKey:@"timelineInfo"]) {
        
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundColor = [UIColor whiteColor];
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        hudView.clipsToBounds = YES;
        hudView.layer.cornerRadius = 10.0;
        
        UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        captionLabel.backgroundColor = [UIColor clearColor];
        captionLabel.textColor = [UIColor whiteColor];
        captionLabel.adjustsFontSizeToFitWidth = YES;
        captionLabel.textAlignment = NSTextAlignmentCenter;
        captionLabel.text = @"Pull Down to Refresh";
        [hudView addSubview:captionLabel];
        [self.tableView addSubview:hudView];
        [hudView setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2)];

    } else {
        timelineInfo = [NSKeyedUnarchiver unarchiveObjectWithData:timelineData];
        [tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(startrefreshing) forControlEvents:UIControlEventValueChanged];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl beginRefreshing];
        [self.refreshControl endRefreshing];
    });
    
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tweetButton.frame = CGRectMake(0, 0, 38, 44);
    [tweetButton setImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
    [tweetButton addTarget:self action:@selector(goToTwitter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *tweetButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tweetButton];
    [tweetButton setTintColor:[UIColor whiteColor]];
    
    NSArray *rightItems = [[NSArray alloc] initWithObjects:tweetButtonItem, nil];
    [[self navigationItem] setRightBarButtonItems:rightItems];
    
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    self.title = @"News Feed";
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)startrefreshing
{
    [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing..."]];
    [self.refreshControl beginRefreshing];
    [self performSelector:@selector(fetchTimelineForUser:) withObject:@"BFRO_Updates" afterDelay:1.5];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    [hudView removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Go To Twitter
-(void)goToTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=BFRO_Updates"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=BFRO_Updates"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/BFRO_Updates"]];
    }
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tv heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
      return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 180 : 160;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return  timelineInfo.count;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the new or recycled cell
    NewsFeedCell  *cell = [tv dequeueReusableCellWithIdentifier:@"NewsFeedCell"];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewsFeedCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];

    return cell;

}

- (void)configureCell:(NewsFeedCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    NSString *imagePath;
    NSString *tweet;
    if ([[[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"entities.user_mentions"] count] > 0) {
        [[cell name] setText:[[[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"entities.user_mentions.name"] objectAtIndex:0]];
        [[cell userName] setText:[@"@" stringByAppendingString:[[[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"entities.user_mentions.screen_name"] objectAtIndex:0]]];
        imagePath = [[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"retweeted_status.user.profile_image_url"];
        tweet = [[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"retweeted_status.text"];
        
        [cell retweeted].text = @"BFRO Updates retweeted";

    } else {
        [[cell name] setText:[[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"user.name"]];
        [[cell userName] setText:[@"@" stringByAppendingString:[[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"user.screen_name"]]];
        imagePath = [[timelineInfo objectAtIndex:indexPath.row] valueForKeyPath:@"user.profile_image_url"];
        tweet = [[timelineInfo objectAtIndex:indexPath.row] valueForKey:@"text"];
    }
    
    imagePath = [imagePath stringByReplacingOccurrencesOfString:@"_normal.png" withString:@".png"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imagePath]];
    [cell.profilePic setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"bfroImage"]
                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
                                        [cell.profilePic setImage:image];
                                    }
                                    failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *err){
                                    }

     ];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:usLocale];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *date = [dateFormatter dateFromString:[[timelineInfo objectAtIndex:indexPath.row] valueForKey:@"created_at"]];
    [dateFormatter setDateFormat:@"dd MMM yy"];
    

    [cell.name setAdjustsFontSizeToFitWidth:YES];
    [cell.userName setAdjustsFontSizeToFitWidth:YES];

    [cell profilePic].layer.cornerRadius = 5.0;
    [cell profilePic].clipsToBounds = YES;
    
    [[cell tweetDate] setText:[dateFormatter stringFromDate:date]];
    cell.tweetDate.font = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? [UIFont fontWithName:@"HelveticaNeue-Bold" size:12] : [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    
    [[cell tweet] setText:nil];
    [[cell tweet] setText:[tweet stringByDecodingHTMLEntities]]; //Helvetica Neue Bold 12.0
    cell.tweet.font = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? [UIFont fontWithName:@"Helvetica Neue" size:13] : [UIFont fontWithName:@"Helvetica Neue" size:16];
    [cell.tweet setScrollEnabled:NO];
    [cell.tweet setDelegate:self];
}

#pragma mark - fetchTimeline

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    ImageViewController *ivc = [[ImageViewController alloc] init];
    [ivc setUrl:URL];
    ivc.edgesForExtendedLayout = UIRectEdgeNone;
    ivc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:ivc animated:YES];

    return NO;
}

- (void)fetchTimelineForUser:(NSString *)username
{
    //  Step 0: Check that the user has local Twitter accounts
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"MPHXftc2P8dwcQFaVqXjw"
                                                            consumerSecret:@"loQZclbPyX01TrCuCIwkmhggjHQTKVsxRE2Xx1A9FLQ"];
    
    [twitter verifyCredentialsWithSuccessBlock:^(NSString *bearerToken) {
        
        [twitter getUserTimelineWithScreenName:username
                                  successBlock:^(NSArray *statuses) {
                                      [self.refreshControl endRefreshing];
                                      [hudView removeFromSuperview];
                                      self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];

                                      timelineInfo = statuses;

                                      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                                      NSData *data = [NSKeyedArchiver archivedDataWithRootObject:timelineInfo];
                                      [defaults setObject:data forKey:@"timelineInfo"];
                                      [defaults synchronize];
                                      
                                      //[noReportsLabel removeFromSuperview];
                                      tableView.backgroundColor = [UIColor whiteColor];
                                      [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                                      [tableView reloadData];

                                      // ...
                                  } errorBlock:^(NSError *error) {
                                      [self.refreshControl endRefreshing];
                                      [hudView removeFromSuperview];
                                      self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];

                                      [tableView makeToast:error.localizedDescription duration:2.0 position:@"center"];
                                      // ...
                                  }];
        
    } errorBlock:^(NSError *error) {
        [tableView makeToast:error.localizedDescription duration:2.0 position:@"center"];
        [self.refreshControl endRefreshing];
        [hudView removeFromSuperview];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];

    }];
}
@end
