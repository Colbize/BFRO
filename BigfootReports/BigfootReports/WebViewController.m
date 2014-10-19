//
//  WhatisBigfootWebViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/23/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "WebViewController.h"
#import "ImageViewController.h"
#import "PopoverView.h"
#import "MapPoint.h"

@interface WebViewController ()
{
    MKMapView *map;
    CLLocationCoordinate2D touchMapCoordinate;
}
@end

@implementation WebViewController
@synthesize webView, htmlString, urlString;

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
    UIColor * color = [UIColor colorWithRed:255/255.0f green:189/255.0f blue:4/255.0f alpha:1.0f];
    [self.navigationController.navigationBar setBarTintColor:color];
    //[[self.navigationController navigationBar] setBarTintColor:[UIColor colorWithRed:255/255.0f green:77/255.0f blue:77/255.0f alpha:1.0f]];
    
    webView.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    map = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-40, self.view.frame.size.height/2-50)];
}

- (void)viewWillLayoutSubviews
{
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tabBarController.tabBar.hidden = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? YES : NO;
    
    [webView setDelegate:self];
    
    NSString *DescriptionHTML = [NSString stringWithFormat:@"<html> \n"
                                 "<head> \n"
                                 "<style type=\"text/css\"> img { max-width: 100%; width: auto; height: auto; display: block; margin: 0 auto;}  \n"
                                 "body {font-family: \"%@\"; color:#FFFFFF; font-size: %@;}\n"
                                 "</style> \n"
                                 "</head> \n"
                                 "<body>%@ \n Copyright © 2014 BFRO.net </body>"
                                 "</html>", @"Helvetica Neue", [NSNumber numberWithInt:17], htmlString];
    
    [self.webView loadHTMLString:DescriptionHTML baseURL:[NSURL URLWithString:urlString]];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    webView.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL isEqual:[NSURL URLWithString:@"http://bfro.net/reports_acceptor.asp"]]) {
        return YES;
    }
    
    if ([request.URL isEqual:[NSURL URLWithString:@"http://bfro.net/GDB/displayMapPopover.htm"]]) {
        UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                              initWithTarget:self action:@selector(handleLongPress:)];
        lpgr.minimumPressDuration = 1.0; //user needs to press for 2 seconds
        [map addGestureRecognizer:lpgr];
        
        [PopoverView showPopoverAtPoint:self.view.center inView:self.view withTitle:@"Tap and Hold on a Location" withContentView:map delegate:self];
        
        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"http"] && ![request.URL isEqual:[NSURL URLWithString:urlString]]) {
        ImageViewController *ivc = [[ImageViewController alloc] init];
        [ivc setUrl:request.URL];
        [self.navigationController pushViewController:ivc animated:YES];
        
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    if ([wv.request.URL isEqual:[NSURL URLWithString:@"http://bfro.net/reports_acceptor.asp"]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Your report has been successfully submitted to the BFRO." message:@" Important Note: The BFRO receives many reports each day. Often it takes time for the investigators and researchers who handle the communications to reply to witnesses. Do not be offended if no one responds to you immediately. It does not mean your information has been disregarded. \n\nSighting reports come in waves. When we receive many reports, such as in the summer, the response time is is typically longer, and priority is given to the most recent incidents. Eventually all legitimate reports are checked out. \n\nIf several weeks pass and you are not contacted about your report, please use the comment form to follow up. Mention your contact information, sighting location/date information again, and that no one has responded the first time. Your persistence will be rewarded. \n\nThanks for all your support!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
}

-(void)webview:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
    [self.view makeToast:error.localizedDescription duration:2 position:@"Center"];
}

- (void)popoverViewDidDismiss:(PopoverView *)popoverView;
{
    if (touchMapCoordinate.latitude && touchMapCoordinate.longitude) {
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('location').value = 'Location on Map: %f, %f'", touchMapCoordinate.latitude, touchMapCoordinate.longitude]];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:map];
    touchMapCoordinate =
    [map convertPoint:touchPoint toCoordinateFromView:map];
    
    MapPoint *mp = [[MapPoint alloc] initWithCoordinate:touchMapCoordinate
                                                  title:@"Location of Sighting"
                                               subtitle:[NSString stringWithFormat:@"%f, %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude]];
    // remove any other annotaions
    [map removeAnnotations:[map annotations]];
    // Add it to the map view
    [map addAnnotation:mp];
    [map selectAnnotation:mp animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
