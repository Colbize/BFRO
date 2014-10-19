//
//  AltFrontViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 2/3/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "AltFrontViewController.h"
#import "TWTSideMenuViewController.h"
#import "EveryReportViewController.h"
#import "ChooseReportLocationViewController.h"
#import "WebViewController.h"


@interface AltFrontViewController ()

@end

@implementation AltFrontViewController
@synthesize spinner;

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
    [self.tabBarController.tabBar setHidden:NO];
    UIColor * color = [UIColor colorWithRed:54/255.0f green:55/255.0f blue:58/255.0f alpha:1.0f];
    [[self.navigationController navigationBar] setBarTintColor:color];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.browseReports setEnabled:YES];
    [self.submitAReport setEnabled:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // OPEN DRAWER BUTTON
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:Nil
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self action:@selector(revealMenu)];
    [menuButton setImage:[UIImage imageNamed:@"menuButton"]];
    [menuButton setTintColor:[UIColor whiteColor]];

    [[self navigationItem] setLeftBarButtonItem:menuButton];
    
    // Info button
    
   UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Report Info"
                                                  style:UIBarButtonItemStylePlain
                                                 target:self action:@selector(info)];
    
    [infoButton setTintColor:[UIColor whiteColor]];
    
    NSArray *rightItems = [[NSArray alloc] initWithObjects: infoButton, nil];
    [[self navigationItem] setRightBarButtonItems:rightItems];

}

# pragma mark - info Button
- (void)info
{
    UIViewController *reportInfo = [[UIViewController alloc] initWithNibName:@"reportInfo" bundle:nil];
    reportInfo.edgesForExtendedLayout = UIRectEdgeNone;
    [self.navigationController pushViewController:reportInfo animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - reveal menu
- (void)revealMenu
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
}

# pragma mark - button menu

- (IBAction)recentReports:(id)sender {
    [self.recentReports setEnabled:NO];
    [self.browseReports setEnabled:NO];
    [self.submitAReport setEnabled:NO];
    [spinner startAnimating];
    [self performSelector:@selector(loadRecentReports) withObject:nil afterDelay:1];
}

- (void)loadRecentReports
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy"];
    
    [df setDateFormat:@"MMMM yyyy"];
    
    NSDate *startDate = [df dateFromString:[@"January " stringByAppendingString:@"2013"]];
    NSDate *endDate = [NSDate date];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation" inManagedObjectContext:[[BFROStore sharedStore] context]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"dateOfSighting" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"witnessSubmitted >= %@ && witnessSubmitted <= %@", startDate, endDate];
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setEntity:entity];
    EveryReportViewController *arvc = [[EveryReportViewController alloc] initwithFetchRequest:fetchRequest titleName:nil];
    arvc.title = @"Recent Sightings";
    [spinner stopAnimating];
    [self.navigationController pushViewController:arvc animated:YES];
    [self.browseReports setEnabled:YES];
    [self.submitAReport setEnabled:YES];
    [self.recentReports setEnabled:YES];


}

- (IBAction)browseReports:(id)sender {
    ChooseReportLocationViewController *crlvc = [[ChooseReportLocationViewController alloc] init];
    [self.navigationController pushViewController:crlvc animated:YES];
}

- (IBAction)submitReport:(id)sender
{
    WebViewController *webViewController = [[WebViewController alloc] init];
    [webViewController setHtmlString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"submitAReport" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil]];
    [webViewController setUrlString:@"http://bfro.net/GDB/submitfm.asp"];
    webViewController.title = @"Sighting Report Form";
    [self.navigationController pushViewController:webViewController animated:YES];
}

@end
