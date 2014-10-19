//
//  ImageViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 12/17/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
{
    UIView *hudView;
    UIActivityIndicatorView *aiView;
}
@end

@implementation ImageViewController
@synthesize webView, url, progress, toolBar, forward, back, homeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillLayoutSubviews
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [[self.navigationController navigationBar] setBarTintColor:[UIColor blackColor]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
    
    [[self.navigationController navigationBar] setBarTintColor:[UIColor blackColor]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [toolBar setAlpha:0.9];
    
    [forward setImage:[UIImage imageNamed:@"forward"]];
    [back setImage:[UIImage imageNamed:@"back"]];
    [homeButton setImage:[UIImage imageNamed:@"home"]];
    
    [webView setDelegate:self];
    
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:NO];
    [webView setBackgroundColor:[UIColor blackColor]];
    
    NSString *currentURL = [NSString stringWithFormat:@"%@", url];
    if ([currentURL isEqualToString:@"http://www.rabblerouserindustries.com/categories/BFRO/"]) {
        [progress setHidden:YES];
    }
    
    [progress setProgress:0];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:url];
    
    [webView loadRequest:nsrequest MIMEType:nil textEncodingName:nil
                progress:^( NSUInteger bytesRead , long long progressContentLength , long long expectedContentLength ){
                    CGFloat progressCount = 0;
                    if (expectedContentLength > 0 && progressContentLength <= expectedContentLength) {
                        progressCount = (CGFloat) progressContentLength / expectedContentLength;
                    }
                    else {
                        progressCount = (progressContentLength % 1000000l) / 1000000.0f;
                    }
                    
                    [progress setProgress:progressCount animated:YES];
                } success:^NSData *(NSHTTPURLResponse *response, NSData *data) {
                    return data;
                } failure:^(NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webView Controls
- (IBAction)refresh:(id)sender
{
    [progress setProgress:0];

    [webView setDelegate:self];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:webView.request.URL];
    [webView loadRequest:nsrequest MIMEType:nil textEncodingName:nil
                progress:^( NSUInteger bytesRead , long long progressContentLength , long long expectedContentLength ){
                    CGFloat progressCount = 0;
                    if (expectedContentLength > 0 && progressContentLength <= expectedContentLength) {
                        progressCount = (CGFloat) progressContentLength / expectedContentLength;
                    }
                    else {
                        progressCount = (progressContentLength % 1000000l) / 1000000.0f;
                    }
                    
                    [progress setProgress:progressCount animated:YES];
                } success:^NSData *(NSHTTPURLResponse *response, NSData *data) {
                    return data;
                } failure:^(NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }];

}

#pragma mark - action methods
- (IBAction)back:(id)sender {    
    [webView goBack];
}

- (IBAction)forward:(id)sender {
    
    [webView goForward];
}

- (IBAction)share:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Open in Safari", @"Copy Link", @"Send as Message", nil];
    [sheet showFromToolbar:toolBar];
}

- (IBAction)goHome:(id)sender {
    
    [progress setProgress:0];
    
    [webView setDelegate:self];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:url];
    [webView loadRequest:nsrequest MIMEType:nil textEncodingName:nil
                progress:^( NSUInteger bytesRead , long long progressContentLength , long long expectedContentLength ){
                    CGFloat progressCount = 0;
                    if (expectedContentLength > 0 && progressContentLength <= expectedContentLength) {
                        progressCount = (CGFloat) progressContentLength / expectedContentLength;
                    }
                    else {
                        progressCount = (progressContentLength % 1000000l) / 1000000.0f;
                    }
                    
                    [progress setProgress:progressCount animated:YES];
                } success:^NSData *(NSHTTPURLResponse *response, NSData *data) {
                    return data;
                } failure:^(NSError *error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }];    

}

#pragma mark - alertview
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Message"]) {
        MFMessageComposeViewController *messageVC = [[MFMessageComposeViewController alloc] init];
        [messageVC setMessageComposeDelegate:self];
        if ([MFMessageComposeViewController canSendText]) {
            messageVC.body = [NSString stringWithFormat:@"%@", url];
            [self presentViewController:messageVC animated:YES completion:nil];
        }
    } else if([title isEqualToString:@"E-mail"]) {
        MFMailComposeViewController *messageVC = [[MFMailComposeViewController alloc] init];
        [messageVC setMailComposeDelegate:self];
        if ([MFMailComposeViewController canSendMail]) {
            [messageVC setMessageBody:[NSString stringWithFormat:@"%@", url] isHTML:NO];
            [self presentViewController:messageVC animated:YES completion:nil];
        }
    }
}


#pragma mark - actionsheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([title isEqualToString:@"Open in Safari"]) {
            [[UIApplication sharedApplication] openURL:url];
    } else if ([title isEqualToString:@"Copy Link"]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [NSString stringWithFormat:@"%@", url];
        [self.view makeToast:@"Copied!" duration:1.5 position:@"center"];
    } else if ([title isEqualToString:@"Send as Message"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Report Info Via" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Message",@"E-mail", nil];
        [alert show];
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


#pragma mark - webview methods
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (![error.localizedDescription isEqualToString:@"Plug-in handled load"]) {
    }
    
    NSLog(@"%@", error);
}

- (BOOL)webView:(UIWebView *)myWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
{
    [webView canGoBack];
    [webView canGoForward];
    
    return YES;
}
@end
