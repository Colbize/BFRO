//
//  ReportsViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 12/16/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "ReportsViewController.h"
#import "ReportsByLocation.h"
#import "ImageViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "USACountiesByLocation.h"
#import "Location.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <QuartzCore/QuartzCore.h>
#import "reportMapViewController.h"

static NSString * const kClientId = @"134355214729-vcf2fqdol14t653r45lsu5avh2stbtc8.apps.googleusercontent.com";

@interface ReportsViewController ()
{
    UIButton *addToFavorites;
    int tapCount;
    UIView *hudView;
    UIActivityIndicatorView *aiView;
    UIActionSheet *sheet;
    UIButton *message;
    NSString *myDescriptionHTML;
    int changeFont;
}

@end

@implementation ReportsViewController
@synthesize webView, goToTop, reportInfo, signInButton, searchedString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"";
    }
    return self;
}

#pragma mark - UIWebView Delegates

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"http"]
        && ([[NSString stringWithFormat:@"%@",request.URL] rangeOfString:@"maps.google.com"].location == NSNotFound)
        && ([[NSString stringWithFormat:@"%@",request.URL] rangeOfString:@"www.youtube.com/embed/"].location == NSNotFound)
        && ([[NSString stringWithFormat:@"%@",request.URL] rangeOfString:@"maps.gstatic.com"].location == NSNotFound))
    {
        ImageViewController *ivc = [[ImageViewController alloc] init];
        [ivc setUrl:request.URL];
        [self.navigationController pushViewController:ivc animated:YES];
        
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)wv
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{

    [webView.scrollView flashScrollIndicators];
    
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error
{
    NSLog(@"%@", error);

}

# pragma mark - scroll view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    
        if (scrollView.contentOffset.y > 210) {
            [goToTop setHidden:NO];
            [self.navigationController setNavigationBarHidden:YES animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                    withAnimation:UIStatusBarAnimationSlide];

        }

        if (scrollView.contentOffset.y < 200) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                    withAnimation:UIStatusBarAnimationSlide];
            [goToTop setHidden:YES];
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
}

#pragma mark - load views
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

}

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    changeFont = 1;
    
    [webView setDelegate:self];
    
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    [self.webView.scrollView setDelegate:self];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    self.webView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    int kFieldFontSize = 15;
    
    myDescriptionHTML = @"";
    
    if ([reportInfo.reportHTML isEqualToString:@""] || !reportInfo.reportHTML) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to Load Report" message:@"There was an issue when attempting to load this report.  If this persists please email support using the submit a bug form." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        myDescriptionHTML = [NSString stringWithFormat:@"Report failed to load.. You can access the direct link by tapping here: %@", reportInfo.link];
    } else {
        NSString *fromString = @"<span class=reportheader>";
        NSRange fromRange = [reportInfo.reportHTML rangeOfString:fromString];
        
        NSString *toString = @"</BODY>";
        NSRange toRange = [reportInfo.reportHTML rangeOfString:toString];
        
        NSRange range = NSMakeRange(fromRange.location + fromRange.length, toRange.location - (fromRange.location + fromRange.length));
        
        if (range.length == 0)
        {
            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load page.. Please try again later." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [view show];
        } else {

            NSString *result = [reportInfo.reportHTML substringWithRange:range];
            NSError *error;
            
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<img\\s[\\s\\S]*?src\\s*?=\\s*?['\"](.*?)['\"][\\s\\S]*?>)+?"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
            
            myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                           "<head> \n"
                                           "<style type=\"text/css\"> img { max-width: 200%; width: auto; height: auto; display: block; margin: 0 auto;}  \n"
                                           "body {font-family: \"%@\"; color:#FFFFFF; font-size: %@;}\n"
                                           "</style> \n"
                                           "</head> \n"
                                           "<body><span class=reportheader>%@ \n Copyright © 2014 BFRO.net </body>"
                                           "</html>", @"Helvetica Neue", [NSNumber numberWithInt:kFieldFontSize], result];
            
            if (self.containsImageYN == YES) {
                myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"/gdb/ReportImages/"
                                                                                 withString:@"http://www.bfro.net/gdb/ReportImages/"];
                
                __block NSMutableArray *urlArray = [[NSMutableArray alloc] init];

                [regex enumerateMatchesInString:myDescriptionHTML
                                        options:0
                                          range:NSMakeRange(0, [myDescriptionHTML length])
                                     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                         //NSLog(@"%@", [myDescriptionHTML substringWithRange:[result rangeAtIndex:2]]);
                                         [urlArray addObject:[myDescriptionHTML substringWithRange:[result rangeAtIndex:2]]];
                                     }];
                
                for (NSString *url in urlArray) {
                    if (!([url rangeOfString:@"investigators.bfro.net"].location == NSNotFound)) {
                        myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<img src=\"%@\">", url]
                                                                                         withString:[NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@\"></a>",url, url]];
                    }
                    
                   if (!([url rangeOfString:@"/gdb/ReportImages/"].location == NSNotFound)) {
                        myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<img src=\"%@\" align=\"middle\" border=\"0\" vspace=\"20\">", url]
                                                                                         withString:[NSString stringWithFormat:@"<a href=\"%@\"><img src=\"%@\" align=\"middle\" border=\"0\" vspace=\"20\"></a>",url, url]];
                   }
                }
            }
            
            if (searchedString.length > 0) {
                NSArray *array = [[NSArray alloc] init];
                array = [searchedString componentsSeparatedByString:@" "];
                for (NSString *s in array) {
                    if (s.length > 2)
                        myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:s
                                                                                     withString:[NSString stringWithFormat:@"<FONT COLOR=\"#FFFF00\">%@</FONT>",s]];
                }
            }
        }
        
        [webView loadHTMLString:NSLocalizedString(myDescriptionHTML, nil) baseURL:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;

    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    
    [goToTop setHidden:YES];
    
    // CHANGE FONT SIZE
    UIButton *fontSize = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fontSize.frame = CGRectMake(0, 0, 38, 44);
    [fontSize setImage:[UIImage imageNamed:@"increase_font"] forState:UIControlStateNormal];
    [fontSize addTarget:self action:@selector(changeFontSize) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *font = [[UIBarButtonItem alloc] initWithCustomView:fontSize];
    
    
    // GO TO WEBSITE BUTTON
    UIButton *goToMap = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    goToMap.frame = CGRectMake(0, 0, 38, 44);
    [goToMap setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [goToMap addTarget:self action:@selector(goToMap) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *map = [[UIBarButtonItem alloc] initWithCustomView:goToMap];

    
    // MESSAGE BUTTON
    message = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    message.frame = CGRectMake(0, 0, 38, 44);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:reportInfo.reportID]) {
        [message setImage:[UIImage imageNamed:@"read_message"] forState:UIControlStateNormal];
        [message setTintColor:self.view.tintColor];
    } else {
        [message setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [message setTintColor:self.view.tintColor];
    }
    [message addTarget:self action:@selector(messageRead) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mess = [[UIBarButtonItem alloc] initWithCustomView:message];
    
    // UIACTION SHEET
     sheet = [[UIActionSheet alloc] initWithTitle:@"Share Report via:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook", @"Twitter", @"Copy Link", @"Send as Message", nil];
    
    
    // ADD TO FAVORITES BUTTON
    addToFavorites = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addToFavorites.frame = CGRectMake(0, 0, 38, 44);
    
    NSMutableDictionary *favoritesDic = [[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"];
    
    if (favoritesDic) {
        if ([favoritesDic objectForKey:reportInfo.reportID]) {
            [addToFavorites setImage:[UIImage imageNamed:@"hearts"] forState:UIControlStateNormal];
            [addToFavorites setTintColor:[UIColor redColor]];
        }
        else {
            [addToFavorites setImage:[UIImage imageNamed:@"hearts"] forState:UIControlStateNormal];
            [addToFavorites setTintColor:self.view.tintColor];
        }
    }
    [addToFavorites addTarget:self action:@selector(addToFavorites) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *atf = [[UIBarButtonItem alloc] initWithCustomView:addToFavorites];
    
    // GO TO WEBSITE BUTTON
    UIButton *website = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    website.frame = CGRectMake(0, 0, 38, 44);
    [website setImage:[UIImage imageNamed:@"domain"] forState:UIControlStateNormal];
    [website addTarget:self action:@selector(goToOriginalLink) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *websiteLink = [[UIBarButtonItem alloc] initWithCustomView:website];
    
    // SHARE BUTTON
    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"Share"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(share)];
    [share setTintColor:self.view.tintColor];
    
    NSArray *rightItems;
    // Hide if not available
    if (!(reportInfo.latitude && reportInfo.longitude)) {
        // SET NAV BUTTONS
        rightItems = [[NSArray alloc] initWithObjects:share, websiteLink, font, atf, mess, nil];
    } else {
        rightItems = [[NSArray alloc] initWithObjects:share, websiteLink, font, atf, map, mess, nil];
    }
    [[self navigationItem] setRightBarButtonItems:rightItems];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gototop Methods

- (IBAction)goToTop:(id)sender {
    if (webView.scrollView.contentOffset.y >= 200) {

    [self.webView.scrollView setContentOffset:CGPointMake(0, -20) animated:YES];
    }
}

# pragma mark - share method
- (void)share
{
    
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

# pragma mark - Alert Methods
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMMM yyyy"];
    
    // FACEBOOK SHARE
    if (buttonIndex == 0) {
        
        // If the Facebook app is installed and we can present the share dialog
        if ([FBDialogs canPresentMessageDialog]) {
            
            // Present share dialog
            [FBDialogs presentShareDialogWithLink:[NSURL URLWithString:reportInfo.link]
                                             name:[NSString stringWithFormat:@"ReportID: %@ - %@", reportInfo.reportID, [dateFormatter stringFromDate:reportInfo.dateOfSighting]]
                                          caption:[NSString stringWithFormat:@"Sighting Location: %@ %@", reportInfo.usaCountyReports.location.name, reportInfo.usaCountyReports.name]
                                      description:reportInfo.shortDesc
                                          picture:[NSURL URLWithString:@"https://pbs.twimg.com/profile_images/2732515089/5b2ae2bfeb46e5f0bb034ec273712f48.png"]
                                      clientState:nil
                                          handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                              if(error) {
                                                  // An error occurred, we need to handle the error
                                                  // See: https://developers.facebook.com/docs/ios/errors
                                                  NSLog(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                  [self.view makeToast:@"Unable to post at this time.." duration:2 position:@"center"];

                                              } else {
                                                  NSLog(@"%@", results);
                                                  // Success
                                              }
                                          }];
            
            // If the Facebook app is NOT installed and we can't present the share dialog
        } else {
            // FALLBACK: publish just a link using the Feed dialog
            
            // Put together the dialog parameters
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: [NSURL URLWithString:reportInfo.link], [NSString stringWithFormat:@"ReportID: %@ - %@", reportInfo.reportID, [dateFormatter stringFromDate:reportInfo.dateOfSighting]], [NSString stringWithFormat:@"Sighting Location: %@ %@", reportInfo.usaCountyReports.location.name, reportInfo.usaCountyReports.name],
                                           nil];
            
            // Show the feed dialog
            [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                                   parameters:params
                                                      handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                          if (error) {
                                                              // An error occurred, we need to handle the error
                                                              // See: https://developers.facebook.com/docs/ios/errors
                                                              NSLog(@"%@",[NSString stringWithFormat:@"Error publishing story: %@", error.description]);
                                                          } else {
                                                              if (result == FBWebDialogResultDialogNotCompleted) {
                                                                  // User canceled.
                                                                  NSLog(@"User cancelled.");
                                                              } else {
                                                                  // Handle the publish feed callback
                                                                  NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                                  
                                                                  if (![urlParams valueForKey:@"post_id"]) {
                                                                      // User canceled.
                                                                      NSLog(@"User cancelled.");
                                                                      
                                                                  } else {
                                                                      // User clicked the Share button
                                                                     

                                                                  }
                                                              }
                                                          }
                                                      }];
        }

    // TWITTER SHARE
    } else if (buttonIndex == 1) {
        
        //  Create an instance of the Tweet Sheet
        
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               
                                               composeViewControllerForServiceType:
                                               
                                               SLServiceTypeTwitter];
        
        // Sets the completion handler.  Note that we don't know which thread the
        
        // block will be called on, so we need to ensure that any required UI
        
        // updates occur on the main queue
        
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            
            switch(result) {
                    
                    //  This means the user cancelled without sending the Tweet
                    
                case SLComposeViewControllerResultCancelled:
                    
                    break;
                    
                    //  This means the user hit 'Send'
                    
                case SLComposeViewControllerResultDone:
                {
                    [self.view makeToast:@"Tweeted!" duration:1.5 position:@"center"];
                    break;
                }
                    
            }
            
        };
        
        //  Set the initial body of the Tweet
        if (reportInfo.shortDesc.length >= 117) {
        [tweetSheet setInitialText:[NSString stringWithFormat:@"\"%@\"...", [reportInfo.shortDesc substringFromIndex:115]]];
        } else {
            [tweetSheet setInitialText:[NSString stringWithFormat:@"\"%@\"", reportInfo.shortDesc]];
        }
        
        //  Add an URL to the Tweet.  You can add multiple URLs.
        NSError *error;
        NSString *tinyURL =  [NSString stringWithContentsOfURL:
                              [NSURL URLWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@", reportInfo.link]]
                                                      encoding:NSASCIIStringEncoding error:&error];
        
        if (![tweetSheet addURL:[NSURL URLWithString:tinyURL]]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to add url.." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            
        }
        
        
        //  Presents the Tweet Sheet to the user
        
        [self presentViewController:tweetSheet animated:YES completion:^{
            
        }];
        
    } else if (buttonIndex == 2) {
        
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@", reportInfo.link];
        [self.view makeToast:@"Copied!" duration:1.5 position:@"center"];
        
    } else if (buttonIndex == 3) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Report Info Via" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Message",@"E-mail", nil];
        [alert show];
    }
}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];

    if ([title isEqualToString:@"Message"]) {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        [messageVC setMessageComposeDelegate:self];
        if ([MFMessageComposeViewController canSendText]) {
            messageVC.body = NSLocalizedString(([NSString stringWithFormat:@"Hey check out the MyCitySports App to conveniently access all of your CSC sports team information.\n https://itunes.apple.com/us/app/MyCitySports/id680262157?mt=8&uo=4"]), nil);
        }
    } else if([title isEqualToString:@"E-mail"]) {
        MFMailComposeViewController *messageVC = [[MFMailComposeViewController alloc] init];
        [messageVC setMailComposeDelegate:self];
        if ([MFMailComposeViewController canSendMail]) {
            [messageVC setMessageBody:[NSString stringWithFormat:@"%@ \n %@", reportInfo.shortDesc,reportInfo.link] isHTML:NO];
            [self presentViewController:messageVC animated:YES completion:nil];
        }
    } else {
        
    }
}

#pragma mark - Message delegate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;
        case MessageComposeResultSent:
        {
            [self.view makeToast:@"Sent!" duration:1.5 position:@"center"];
        }
            break;
        case MessageComposeResultFailed:
        {
            [self.view makeToast:@"Unable to Send at This Time." duration:1.5 position:@"center"];
            
        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSent:
        {
            [self.view makeToast:@"Sent!" duration:1.5 position:@"center"];
        }
            break;
        case MFMailComposeResultFailed:
        {
            [self.view makeToast:@"Unable to Send at This Time." duration:1.5 position:@"center"];
            
        }
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Google+ methods
- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    NSLog(@"%@", error);
    if (!error) {
        
        [GPPShare sharedInstance].delegate = self;

        id<GPPNativeShareBuilder> shareBuilder = [[GPPShare sharedInstance] nativeShareDialog];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMMM yyyy"];
        
        // This line will fill out the title, description, and thumbnail from
        // the URL that you are sharing and includes a link to that URL.
        [shareBuilder setURLToShare:[NSURL URLWithString:reportInfo.link]];
        [shareBuilder setPrefillText:[NSString stringWithFormat:@"Date: %@ \nSighting Location: %@, %@", [dateFormatter stringFromDate:reportInfo.dateOfSighting],  reportInfo.usaCountyReports.name, reportInfo.usaCountyReports.location.name]];

        [shareBuilder open];
    } else {
        [self.view makeToast:@"An Error Occurred... Please Try Again." duration:2 position:@"Center"];
    }
}

// Reports the status of the share action.  |error| is nil upon success.  This callback takes
// preference over |finishedSharing:|.  You should implement one of these.
- (void)finishedSharingWithError:(NSError *)error
{
    UIAlertView *alert;
    
    if (!error) {
        [self.view makeToast:@"Shared!" duration:1.5 position:@"center"];

    } else if (error.code == kGPPErrorShareboxCanceled) {
    
    } else {
        [self.view makeToast:@"Failed to Share!" duration:1.5 position:@"center"];

    }
    [alert show];

}

#pragma mark - facebook sharing

// FOR FACEBOOK SHARING
// A function for parsing URL parameters returned by the Feed Dialog.
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

#pragma mark - add to favorites

- (void)addToFavorites
{
    NSMutableDictionary *favoritesDic = [[[NSUserDefaults standardUserDefaults] objectForKey:@"favoritesDictionary"] mutableCopy];
    
    UIAlertView *addFav = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    // Check if the Dictionary exists
    if (favoritesDic) {
        // check if the object already exists
        if ([favoritesDic objectForKey:reportInfo.reportID]) {
            [addToFavorites setImage:[UIImage imageNamed:@"hearts"] forState:UIControlStateNormal];
            [addToFavorites setTintColor:self.view.tintColor];
            [addFav setTitle:[NSString stringWithFormat:@"Removed Report ID: %@ from Favorites", reportInfo.reportID]];
            [favoritesDic removeObjectForKey:reportInfo.reportID];
        } else {
            // Add it
            [addToFavorites setImage:[UIImage imageNamed:@"hearts"] forState:UIControlStateNormal];
            [addToFavorites setTintColor:[UIColor redColor]];
            [addFav setTitle:[NSString stringWithFormat:@"Added Report ID: %@ to Favorites", reportInfo.reportID]];
            [favoritesDic setObject:reportInfo.shortDesc forKey:reportInfo.reportID];
        }
        
    }
    [[NSUserDefaults standardUserDefaults] setObject:favoritesDic forKey:@"favoritesDictionary"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [addFav show];
}

#pragma mark - go to original link 

- (void)goToOriginalLink
{
    ImageViewController *ivc = [[ImageViewController alloc] init];

    [ivc setUrl:[NSURL URLWithString:reportInfo.link]];
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController pushViewController:ivc animated:YES];
}

#pragma mark - message read
- (void)messageRead
{
    UIAlertView *readUnread = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:reportInfo.reportID]) {
        [message setImage:[UIImage imageNamed:@"message"] forState:UIControlStateNormal];
        [message setTintColor:self.view.tintColor];
        [readUnread setTitle:@"Marked Report as Unread."];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:reportInfo.reportID];
    } else {
        // Add it
        [message setImage:[UIImage imageNamed:@"read_message"] forState:UIControlStateNormal];
        [message setTintColor:self.view.tintColor];
        [readUnread setTitle:@"Marked Report as Read."];
         [[NSUserDefaults standardUserDefaults] setBool:YES forKey:reportInfo.reportID];
    }
    [readUnread show];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark - go to map
- (void)goToMap
{
    reportMapViewController *rmvc = [[reportMapViewController alloc] init];
    [rmvc setPointName:reportInfo.reportID];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[reportInfo.latitude doubleValue] longitude:[reportInfo.longitude doubleValue]];
    CLLocationCoordinate2D coord = [loc coordinate];
    
    if (CLLocationCoordinate2DIsValid(coord)) {
        [rmvc setPointLocation:loc];
        [self.navigationController pushViewController:rmvc animated:YES];
        } else {
            [self.view makeToast:@"There was a problem loading the map.." duration:1.5 position:@"center"];
        }
}

#pragma mark - change font size
- (void)changeFontSize
{
    switch (changeFont) {
        case 1:
            myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"font-size: 15;"
                                                                             withString:@"font-size: 17;"];
            changeFont = 2;
            break;
        case 2:
            myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"font-size: 17;"
                                                                             withString:@"font-size: 19;"];
            changeFont = 3;
            break;
        case 3:
            myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"font-size: 19;"
                                                                             withString:@"font-size: 21;"];
            changeFont = 0;
            break;
        default:
            myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"font-size: 21;"
                                                                             withString:@"font-size: 15;"];
            changeFont = 1;
            break;
    }
    [webView loadHTMLString:myDescriptionHTML baseURL:nil];
}


#pragma mark - change image color
- (UIImage *)imageWithColor:(UIColor *)color1 withImage:(UIImage *)img
{
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextClipToMask(context, rect, img.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end
