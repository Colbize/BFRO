//
//  bfroExpeditionsViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/23/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "bfroExpeditionsViewController.h"
#import <UIWebView+AFNetworking.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "WebViewController.h"

@interface bfroExpeditionsViewController ()
{
    NSString *myDescriptionHTML;
}
@end

@implementation bfroExpeditionsViewController
@synthesize webView, contentHolderView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

# pragma mark - sort
- (void)getInfo
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Prepare Yourself Mentally", @"Registration and FAQs", nil];
    
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

# pragma mark - Alert Methods
-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Prepare Yourself Mentally"]) {
        WebViewController *webViewController = [[WebViewController alloc] init];
        [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"prepareMentally" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
        [webViewController setUrlString:@"http://www.bfro.net/green_men.asp"];
        [self.navigationController pushViewController:webViewController animated:YES];
        
    } else if ([title isEqualToString:@"Registration and FAQs"]) {
        WebViewController *webViewController = [[WebViewController alloc] init];
        [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"RegAndFAQs" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
        [webViewController setUrlString:nil];
        [self.navigationController pushViewController:webViewController animated:YES];

    }
}
#pragma mark - webview methods


- (void)webViewDidStartLoad:(UIWebView *)wv
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (![error.localizedDescription isEqualToString:@"Plug-in handled load"]) {
    }
}

#pragma mark - view load methods
- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setTranslucent:NO];

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor whiteColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
    UIColor * color = [UIColor colorWithRed:255/255.0f green:189/255.0f blue:4/255.0f alpha:1.0f];
    [[self.navigationController navigationBar] setBarTintColor:color];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:@"http://www.bfro.net/news/roundup/expeds_2014.asp"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSString *htmlString = [[NSString alloc] initWithData:responseObject
                                                          encoding:NSUTF8StringEncoding];
             
             NSString *fromString = @"</style>";
             NSRange fromRange = [htmlString rangeOfString:fromString];
             
             NSString *toString = @"</BODY>";
             NSRange toRange = [htmlString rangeOfString:toString];
             
             NSRange range = NSMakeRange(fromRange.location + fromRange.length, toRange.location - (fromRange.location + fromRange.length));
             
             if (range.length == 0)
             {
                 UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Unable to load page.. Please try again later or check your internet connection" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                 [view show];
             } else {
                 NSString *result = [htmlString substringWithRange:range];
                 
                 myDescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                      "<head> \n"
                                      "<style type=\"text/css\"> \n"
                                      "body {font-family: \"%@\"; color:#FFFFFF;}\n"
                                      "</style> \n"
                                      "</head> \n"
                                      "<body>%@ \n</body>"
                                      "</html>", @"Helvetica Neue", result];
                 
                 NSString *removeString1 = @"1) If you have never attended a BFRO expedition before then you should <a href=\"../../green_men.asp\">read this page</a> to prepare yourself mentally.";
                 NSString *removeString2 = @" 2) Click here for <a href=\"exped_faq.asp\">REGISTRATION and FAQ</a>";
                 NSString *replaceHeader = @"Steps for Registration:";
                 
                 myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:removeString1 withString:@""];
                 myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:removeString2 withString:@""];
                 myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:replaceHeader withString:@"Tap the \"More Info\" button above for Registration and FAQs information."];
                 myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"<a href=\"http://www.bfro.net/GDB/CNTS/GA/RM/ga_rm001.htm\">encountered by a hunter</a>" withString:@"encountered by a hunter"];
                 myDescriptionHTML = [myDescriptionHTML stringByReplacingOccurrencesOfString:@"<a href=\"http://www.bfro.net/news/korff_scam.asp\">1967 footage</a>" withString:@"1967 footage"];
                 
                 [webView loadHTMLString:myDescriptionHTML baseURL:[NSURL URLWithString:@"http://www.bfro.net/news/roundup/expeds_2014.asp"]];
                 
                 webView.scalesPageToFit = YES;
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
             [alert show];
         }
     ];
             

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    UIBarButtonItem *info = [[UIBarButtonItem alloc] initWithTitle:@"More Info"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self action:@selector(getInfo)];
    [info setTintColor:self.view.tintColor];
    
    NSArray *rightItems = [[NSArray alloc] initWithObjects:info, nil];
    [[self navigationItem] setRightBarButtonItems:rightItems];

    [webView setDelegate:self];
    [self.webView.scrollView setDelegate:self];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    self.webView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
