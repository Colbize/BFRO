//
//  btcAppDelegate.m
//  BigfootReports
//
//  Created by Colby Reineke on 11/24/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "btcAppDelegate.h"
#import "BFROStore.h"
#import "EveryReportViewController.h"
#import <FacebookSDK.h>
#import "SightingsMapViewController.h"
#import "NewsFeedViewController.h"
#import "FAQViewController.h"
#import "bfroExpeditionsViewController.h"
#import "ImageViewController.h"
#import "SideDeckViewController.h"
#import "AltFrontViewController.h"
#import "iRate.h"

@interface btcAppDelegate ()

@property (nonatomic, strong) TWTSideMenuViewController *sideMenuViewController;
@end

@implementation btcAppDelegate
@synthesize tbc;

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 14;
    [iRate sharedInstance].usesUntilPrompt = 6;
    [[iRate sharedInstance] setAppStoreID:826168573];
    [[iRate sharedInstance] setRemindPeriod:7];
    [[iRate sharedInstance] setMessage:@"If you have enjoyed using the B.F.R.O App, would you mind taking a moment to rate it? If there are any issues please contact us! Thank you for your support!"];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSMutableDictionary *favoritesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] mutableCopy];
    
    if (!favoritesDic) {
        favoritesDic = [[NSMutableDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesDic forKey:@"favoritesDictionary"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSMutableDictionary *newReports = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] mutableCopy];
    if (!newReports) {
        newReports = [[NSMutableDictionary alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:newReports forKey:@"RecentlyAdded"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    AltFrontViewController *afvc = [[AltFrontViewController alloc] init];
    
    SideDeckViewController *side = [[SideDeckViewController alloc] init];
    self.sideMenuViewController = [[TWTSideMenuViewController alloc] initWithMenuViewController:side mainViewController:[[UINavigationController alloc] initWithRootViewController:afvc]];
    
    self.sideMenuViewController.shadowColor = [UIColor blackColor];
    self.sideMenuViewController.edgeOffset = (UIOffset) { .horizontal = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 18.0f : 0.0f };
    self.sideMenuViewController.zoomScale = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 0.35f : 0.85f;
    self.sideMenuViewController.delegate = self;
    
    tbc = [[CustomTabBarController alloc] init];
    
    EveryReportViewController *rvc = [[EveryReportViewController alloc] initwithSearchRequest];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:rvc];
    
    SightingsMapViewController *smvc = [[SightingsMapViewController alloc] init];
    UINavigationController *sightingNav = [[UINavigationController alloc] initWithRootViewController:smvc];

    NewsFeedViewController *nfvc = [[NewsFeedViewController alloc] init];
    UINavigationController *newsNav = [[UINavigationController alloc] initWithRootViewController:nfvc];
    
    FAQViewController *faqs = [[FAQViewController alloc] init];
    faqs.title = @"BFRO FAQs";
    faqs.hidesBottomBarWhenPushed = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    UINavigationController *faqNav = [[UINavigationController alloc] initWithRootViewController:faqs];
    
    bfroExpeditionsViewController *exp = [[bfroExpeditionsViewController alloc] init];
    exp.title = @"BFRO Expeditions";
    exp.hidesBottomBarWhenPushed = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    UINavigationController *bfroExp = [[UINavigationController alloc] initWithRootViewController:exp];
    
    ImageViewController *imv;
    
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        imv = [[ImageViewController alloc] initWithNibName:@"ShopViewiPad" bundle:Nil];
        [imv setUrl:[NSURL URLWithString:@"http://www.rabblerouserindustries.com/categories/BFRO/"]];
        imv.title = @"BFRO Gear";
        imv.edgesForExtendedLayout = UIRectEdgeNone;

    } else {
        imv = [[ImageViewController alloc] init];
        [imv setUrl:[NSURL URLWithString:@"http://www.rabblerouserindustries.com/categories/BFRO/"]];
        imv.title = @"BFRO Gear";
        imv.hidesBottomBarWhenPushed = YES;
    }
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:self.sideMenuViewController, searchNav, sightingNav, newsNav, faqNav, bfroExp, imv, nil];
    
    [tbc setViewControllers:viewControllers];
    
    UITabBar *tabBar = tbc.tabBar;
    
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"news"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1.image = [[UIImage imageNamed:@"news"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem1.title = @"Reports";
    
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.image = [[UIImage imageNamed:@"search"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem2.title = @"Search";
    
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"map_marker"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.image = [[UIImage imageNamed:@"map_marker"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem3.title = @"Map of Reports";
    
    tabBarItem4.selectedImage = [[UIImage imageNamed:@"twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem4.image = [[UIImage imageNamed:@"twitter"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    tabBarItem4.title = @"BFRO News";
    
    if (tabBar.items.count > 5) {
        UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
        tabBarItem5.selectedImage = [[UIImage imageNamed:@"help"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem5.image = [[UIImage imageNamed:@"help"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem5.title = @"FAQs";
        
        UITabBarItem *tabBarItem6 = [tabBar.items objectAtIndex:5];
        tabBarItem6.selectedImage = [[UIImage imageNamed:@"camping_tent"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem6.image = [[UIImage imageNamed:@"camping_tent"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem6.title = @"BFRO Expeditions";
        
        UITabBarItem *tabBarItem7 = [tabBar.items objectAtIndex:6];
        tabBarItem7.selectedImage = [[UIImage imageNamed:@"cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem7.image = [[UIImage imageNamed:@"cart"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        tabBarItem7.title = @"BFRO Gear";

    }
           
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = tbc;

    UIColor * color = [UIColor colorWithRed:52/255.0f green:53/255.0f blue:71/255.0f alpha:1.0f];
    // Override point for customization after application launch.
    self.window.backgroundColor = color;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     UIView *view = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [view endEditing:YES];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.

}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    BOOL urlWasHandled = [FBAppCall handleOpenURL:url
                                sourceApplication:sourceApplication
                                  fallbackHandler:^(FBAppCall *call) {
                                      NSLog(@"Unhandled deep link: %@", url);
                                      // Parse the incoming URL to look for a target_url parameter
                                      NSString *query = [url fragment];
                                      if (!query) {
                                          query = [url query];
                                      }
                                      NSDictionary *params = [self parseURLParams:query];
                                      // Check if target URL exists
                                      NSString *targetURLString = [params valueForKey:@"target_url"];
                                      if (targetURLString) {
                                          // Show the incoming link in an alert
                                          // Your code to direct the user to the appropriate flow within your app goes here
                                          [[[UIAlertView alloc] initWithTitle:@"Received link:"
                                                                      message:targetURLString
                                                                     delegate:self
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil] show];
                                      }
                                  }];
    
    return urlWasHandled;
        
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}


@end
