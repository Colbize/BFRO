//
//  SightingsMapViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/6/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "SightingsMapViewController.h"
#import "PopoverView.h"
#import "Location.h"
#import "MapPoint.h"
#import <QuartzCore/QuartzCore.h>
#import "USACountiesByLocation.h"
#import "ReportsByLocation.h"
#import "ReportsViewController.h"

#define HEIGHT_UP 2000
#define HEIGHT_DOWN 475

@interface SightingsMapViewController ()
{
    CLLocationManager *locationManager;
    PopoverView *pop;
    int mType;
    UIActivityIndicatorView *activityView;
    CLGeocoder *geocoder;
    bool findMeYN;
    NSArray *fetchedObjects;
    NSFetchRequest *fetchRequest;
    NSMutableArray *alreadySelected;
    NSString *classID;
    NSString *selectedReportID;
    UIView *hudView;
    UIActivityIndicatorView *aiView;
    UIView *helpView;
    UIView *holdTable;
    UIView *helpPoint;
    bool tableShown;
    
}

- (void)loadReport:(MKAnnotationView *)view;

@end

@implementation SightingsMapViewController
@synthesize tableView, showReports, layers, map, findMe, fetchedResultsController, whiteLabel, eraseAll, infoButton, legendView, theLegendView;

- (id)init
{
    if (self) {
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - tableview methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                             reuseIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                   reuseIdentifier:@"UITableViewCell"];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;

}
- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    Location *info = [fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.textLabel setText:info.name];
}


- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [[fetchedResultsController sections] count];
    
}


- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id  sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tv deselectRowAtIndexPath:indexPath animated:YES];
    
    [self hideTable:holdTable];
    tableShown = NO;
    
    if (!geocoder)
        geocoder = [[CLGeocoder alloc] init];
    
    NSString *location;
    if (indexPath.section == 0) {
        location = [NSString stringWithFormat:@"%@, United States", [tv cellForRowAtIndexPath:indexPath].textLabel.text];
    } else if (indexPath.section == 2) {
        location = [NSString stringWithFormat:@"%@, Canada", [tv cellForRowAtIndexPath:indexPath].textLabel.text];
    } else {
        location = [tv cellForRowAtIndexPath:indexPath].textLabel.text;
    }
    if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Nevada"]) {
        location = @"39.491944, -117.070278";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Oregon"]) {
        location = @"44.303889, -120.846111";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Vermont"]) {
        location = @"44.25, -72.566667";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Washington"]) {
        location = @"47.423333, -120.325278";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Wyoming"]) {
        location = @"43.240278, -108.114444";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Himalayan Region"]) {
        location = @"27.988056, 86.925278";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Other Countries & Regions"]) {
        location = @"Europe";
    } else if ([[tv cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"Virginia"]) {
        location = @"37.533333, -77.466667";
    }
    
    [geocoder geocodeAddressString:location
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (!error) {
                         for (CLPlacemark* aPlacemark in placemarks)
                         {
                             [self foundLocation:aPlacemark.location];
                         }
                     } else {
                         NSLog(@"Error: %@", error.localizedDescription);
                     }
                 }];

    // Process the placemark.
    Location *info = [fetchedResultsController objectAtIndexPath:indexPath];
    if (![alreadySelected containsObject:info.name]) {
        [alreadySelected addObject:info.name];
         if ([info.country isEqualToString:@"USA"]) { // USA REPORTS
                 NSArray *countyArray = [info.countyByLocation allObjects];
                 for (USACountiesByLocation *county in countyArray) {
                     NSArray *reports = [county.reportsByCounty allObjects];
                     for (ReportsByLocation *report in reports) {
                         if (report.longitude.doubleValue && report.latitude.doubleValue) {
                             
                             CLLocation *loc = [[CLLocation alloc] initWithLatitude:report.latitude.doubleValue
                                                                          longitude:report.longitude.doubleValue];
                             
                             CLLocationCoordinate2D coord = [loc coordinate];
                             
                             if (CLLocationCoordinate2DIsValid(coord)) {
                                 // Create an instance of MapPoint with the current data
                                 MapPoint *mp = [[MapPoint alloc] initWithCoordinate:coord
                                                                               title:[@"Report ID: " stringByAppendingString:report.reportID]
                                                                                subtitle:report.shortDesc];
                                 [mp setClassID:report.classSighting];
                                 // Add it to the map view
                                 [map addAnnotation:mp];
                             }
                         }
                     }
                 }
         } else { // ALL OTHER REPORTS
             NSArray *OtherReports = [info.reportsByLocation allObjects];
              for (ReportsByLocation *r in OtherReports) {
                  if (r.longitude.doubleValue && r.latitude.doubleValue) {
                      
                      CLLocation *loc = [[CLLocation alloc] initWithLatitude:r.latitude.doubleValue
                                                                   longitude:r.longitude.doubleValue];
                      
                      CLLocationCoordinate2D coord = [loc coordinate];
                      
                      if (CLLocationCoordinate2DIsValid(coord)) {
                          
                          // Create an instance of MapPoint with the current data
                          MapPoint *mp = [[MapPoint alloc] initWithCoordinate:coord
                                                                        title:[@"Report ID: " stringByAppendingString:r.reportID]
                                                                     subtitle:r.shortDesc];
                          [mp setClassID:r.classSighting];
                          // Add it to the map view
                          [map addAnnotation:mp];
                      }
                  }
              }
         }
    } else {
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"PointTipShown"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PointTipShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        helpPoint = [[[NSBundle mainBundle] loadNibNamed:@"helpTipPoints" owner:nil options:nil] objectAtIndex:0];
        [helpPoint.layer setCornerRadius:30.0f];
        
        // border
        [helpPoint.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [helpPoint.layer setBorderWidth:1.5f];
        
        // drop shadow
        [helpPoint.layer setShadowColor:[UIColor blackColor].CGColor];
        [helpPoint.layer setShadowOpacity:0.8];
        [helpPoint.layer setShadowRadius:3.0];
        [helpPoint.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
        [self.view addSubview:helpPoint];
        [helpPoint setCenter:CGPointMake(self.view.frame.size.width/2, -500)];
        
        [self showHelpTip:helpPoint];
        
        for (UIView *v in helpPoint.subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton * myButton = (UIButton *)v;
                [myButton addTarget:self action:@selector(closeTip) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

# pragma mark - NSFetchedResultsController methods
- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                  managedObjectContext:[[BFROStore sharedStore] context]
                                                                                                    sectionNameKeyPath:@"Country"
                                                                                                             cacheName:nil];
    self.fetchedResultsController = theFetchedResultsController;
    fetchedResultsController.delegate = self;
    
    return fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
    
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
    
}

#pragma mark - show the report
- (void)showTheReport
{
}


#pragma mark - show reports
- (IBAction)showReports:(id)sender
{
    if (tableShown == NO) {
        fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:[[BFROStore sharedStore] context]];
        NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                                  initWithKey:@"country" ascending:NO];
        
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setEntity:entity];

        NSError *error;
        if (![[self fetchedResultsController] performFetch:&error]) {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        holdTable = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x, tableView.frame.origin.y, tableView.frame.size.width, tableView.frame.size.height)];
        holdTable.clipsToBounds = NO;
        holdTable.layer.masksToBounds = NO;
        tableView.clipsToBounds = YES;
        tableView.layer.masksToBounds = YES;
        
        [tableView.layer setCornerRadius:10.0f];
        
        // border
        [tableView.layer setBorderColor:[UIColor groupTableViewBackgroundColor].CGColor];
        [tableView.layer setBorderWidth:6.0f];
        
        // drop shadow
        [holdTable.layer setShadowColor:[UIColor blackColor].CGColor];
        [holdTable.layer setShadowOpacity:0.9];
        [holdTable.layer setShadowRadius:6.0];
        [holdTable.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        [holdTable addSubview:tableView];

        [self.view addSubview:holdTable];
        [holdTable setCenter:CGPointMake(self.view.frame.size.width/2, -500)];
        
        [self showTable:holdTable];
        
        findMeYN = NO;
        tableShown = YES;
    } else {
        [self hideTable:holdTable];
        tableShown = NO;
    }
}

#pragma mark - change layer
- (IBAction)changeLayer:(id)sender {
    switch (mType) {
        case 0:
            map.mapType = MKMapTypeSatellite;
            mType++;
            break;
        case 1:
            map.mapType = MKMapTypeHybrid;
            mType++;
            break;
        default:
            map.mapType = MKMapTypeStandard;
            mType = 0;
            break;
        }
}

#pragma mark - find me method
- (IBAction)findMe:(id)sender {
    [map setShowsUserLocation:YES];
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }

    [locationManager startUpdatingLocation];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        findMeYN = YES;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self.map makeToast:@"Location Service Not Enabled. To Enable go to iPhone Settings > Privacy > Location Services > BFRO to re-enable" duration:7.0 position:@"center"];
    }
}

#pragma mark - map view methods
- (void)foundLocation:(CLLocation *)loc
{
    CLLocationCoordinate2D coord = [loc coordinate];
    
    MKCoordinateRegion region;
    if (findMeYN == NO) {
        // Zoom the region to this location
        region = MKCoordinateRegionMakeWithDistance(coord, 900000, 900000);
    } else {
         region = MKCoordinateRegionMakeWithDistance(coord, 700000, 700000);
    }
    [map setRegion:region animated:YES];
    
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self foundLocation:newLocation];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{

}

#pragma mark - MKAnnotationView methods

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(MapPoint *)annotation
{
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    
    MKPinAnnotationView *MyPin = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"currentloc"];
    if (MyPin == nil) {
        MyPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation   reuseIdentifier:@"currentloc"];
    }
    
    UIButton *goToObjectButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    [goToObjectButton addTarget:self action:@selector(showTheReport)  forControlEvents:UIControlEventTouchUpInside];
    if ([annotation.classID.lowercaseString isEqualToString:@"class a"]) {
        MyPin.pinColor = MKPinAnnotationColorRed;
    } else if ([annotation.classID.lowercaseString isEqualToString:@"class b"]) {
        MyPin.pinColor = MKPinAnnotationColorPurple;
    } else if ([annotation.classID.lowercaseString isEqualToString:@"class c"]) {
        MyPin.pinColor = MKPinAnnotationColorGreen;
    } else {
        MyPin.pinColor = MKPinAnnotationColorGreen;
    }
    
    MyPin.rightCalloutAccessoryView = goToObjectButton;
    MyPin.draggable = NO;
    MyPin.highlighted = NO;
    MyPin.animatesDrop=YES;
    MyPin.canShowCallout = YES;
    
    return MyPin;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{
    [self loading];
    [self performSelector:@selector(loadReport:) withObject:view afterDelay:0];
}

- (void)loadReport:(MKAnnotationView *)view
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"ReportsByLocation"
                                   inManagedObjectContext:[[BFROStore sharedStore] context]];
    [fetch setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(reportID = %@)", [view.annotation.title stringByReplacingOccurrencesOfString:@"Report ID: " withString:@""]];
    
    [fetch setPredicate:predicate];
    
    NSError *error;
    ReportsByLocation *reportsInfo = [[[[BFROStore sharedStore] context] executeFetchRequest:fetch error:&error] lastObject];
    
    ReportsViewController *rvc = [[ReportsViewController alloc] init];
    [rvc setReportInfo:reportsInfo];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    if (error) {
        [self stopLoading];
        [self.map makeToast:@"Failed To Load Report!" duration:1.5 position:@"center"];
    } else {
        [self stopLoading];
        [rvc setReportInfo:reportsInfo];
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController:rvc animated:YES];
        rvc.hidesBottomBarWhenPushed = YES;
        
    }

}

#pragma mark - loading and unloading
- (void)loading
{
    hudView = [[UIView alloc] initWithFrame:CGRectMake(75, 155, 180, 140)];
    hudView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
    hudView.clipsToBounds = YES;
    hudView.layer.cornerRadius = 10.0;
    
    aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    aiView.frame = CGRectMake(69, 40, aiView.bounds.size.width, aiView.bounds.size.height);
    [hudView addSubview:aiView];
    [hudView setCenter:self.view.center];
    [aiView startAnimating];
    
    UILabel *captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 140, 22)];
    captionLabel.backgroundColor = [UIColor clearColor];
    captionLabel.textColor = [UIColor whiteColor];
    captionLabel.adjustsFontSizeToFitWidth = YES;
    captionLabel.textAlignment = NSTextAlignmentCenter;
    captionLabel.text = @"Loading Report..";
    [hudView addSubview:captionLabel];
    [self.view.superview addSubview:hudView];
    
    
}

- (void)stopLoading
{
    [aiView stopAnimating];
    [hudView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
}

#pragma mark - tap recognizer
//- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
//    [self hideTable:holdTable];
//    tableShown = NO;
//}

#pragma mark - view load methods
- (void)viewWillAppear:(BOOL)animated
{
    [tableView setBackgroundColor:[UIColor clearColor]];
    map.delegate = self;
    map.mapType = MKMapTypeStandard;
  
    self.navigationController.navigationBarHidden = YES;
    [self.tabBarController.tabBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewWillLayoutSubviews
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationSlide];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    tableShown = NO;
    
    alreadySelected = [[NSMutableArray alloc] init];
    
    [whiteLabel setAlpha:0.7];
    whiteLabel.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
    whiteLabel.layer.borderWidth = 4.0;
    whiteLabel.layer.cornerRadius = 8;
    
    self.navigationController.navigationBar.translucent = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    [layers setImage:[UIImage imageNamed:@"layers"] forState:UIControlStateNormal];
    [findMe setImage:[UIImage imageNamed:@"near_me"] forState:UIControlStateNormal];
    [showReports setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [eraseAll setImage:[UIImage imageNamed:@"eraser"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    
    [layers setTintColor:[UIColor whiteColor]];
    [findMe setTintColor:[UIColor whiteColor]];
    [showReports setTintColor:[UIColor whiteColor]];
    [eraseAll setTintColor:[UIColor whiteColor]];
    [infoButton setTintColor:[UIColor whiteColor]];

    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, map.frame.size.width/1.5, map.frame.size.height/2) style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    findMeYN = NO;
    
    mType = 0;
    
    [map setDelegate:self];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
//    tapGesture.numberOfTapsRequired = 1;
//    [self.map addGestureRecognizer:tapGesture];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"MapTipShown"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MapTipShown"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        helpView = [[[NSBundle mainBundle] loadNibNamed:@"helpTipMap" owner:nil options:nil] objectAtIndex:0];
               [helpView.layer setCornerRadius:30.0f];
        
        // border
        [helpView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
        [helpView.layer setBorderWidth:1.5f];
        
        // drop shadow
        [helpView.layer setShadowColor:[UIColor blackColor].CGColor];
        [helpView.layer setShadowOpacity:0.8];
        [helpView.layer setShadowRadius:3.0];
        [helpView.layer setShadowOffset:CGSizeMake(2.0, 2.0)];
        
        [self.view addSubview:helpView];
        [helpView setCenter:CGPointMake(self.view.frame.size.width/2, -500)];
        
        [self showHelpTip:helpView];
        
        for (UIView *v in helpView.subviews) {
            if ([v isKindOfClass:[UIButton class]]) {
                UIButton * myButton = (UIButton *)v;
                [myButton addTarget:self action:@selector(closeTip) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationSlide];
    map.delegate = nil;
    map.mapType = MKMapTypeSatellite;
    
    [holdTable removeFromSuperview];
    tableShown = NO;
}


#pragma mark - adjustViewsForOrientation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [pop dismiss:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [map removeAnnotations:[map annotations]];
    // Dispose of any resources that can be recreated.
    
}

#pragma mark - eraseAll

- (IBAction)eraseAll:(id)sender {
    [map removeAnnotations:[map annotations]];
    [alreadySelected removeAllObjects];
}

#pragma mark - infoButton
- (IBAction)infoButton:(id)sender {
    UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"sightingsInfo" owner:self options:nil] objectAtIndex:0];
    [view setBackgroundColor:[UIColor clearColor]];
    [self.redColor.layer setCornerRadius:11];
    [self.purpleColor.layer setCornerRadius:11];
    [self.greenColor.layer setCornerRadius:11];
    pop = [PopoverView showPopoverAtPoint:infoButton.center inView:self.view withContentView:view delegate:nil];

}

#pragma mark - animate tipView
- (void)showTable:(UIView *)view
{
    CGFloat bounceDistance = 100;
    CGFloat bounceDuration = 0.4;
    [UIView animateWithDuration:0.5 delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat direction = (holdTable ? 1 : -1);
                         view.center = CGPointMake(view.center.x, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 475 : 250) + direction*bounceDistance);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:bounceDuration animations:^{
                             view.center = CGPointMake(view.center.x, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 475 : 250));

                         }];
                     }];
}

- (void)hideTable:(UIView *)view
{
    CGFloat bounceDistance = 100;
    CGFloat bounceDuration = 0.4;
    [UIView animateWithDuration:0.5 delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat direction = (holdTable ? 1 : -1);
                         view.center = CGPointMake(view.center.x, HEIGHT_UP + direction*bounceDistance);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:bounceDuration animations:^{
                             view.center = CGPointMake(view.center.x, HEIGHT_UP);
                                 [holdTable removeFromSuperview];
                         }];
                     }];
}

- (void)showHelpTip:(UIView *)view
{
    CGFloat bounceDistance = 100;
    CGFloat bounceDuration = 0.4;
    [UIView animateWithDuration:0.5 delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         CGFloat direction = 1;
                         view.center = CGPointMake(view.center.x, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 475 : 250) + direction*bounceDistance);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:bounceDuration animations:^{
                             view.center = CGPointMake(view.center.x, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad? 475 : 250));
                         }];
                     }];
}

- (void)closeTip
{
    [helpView removeFromSuperview];
    [helpPoint removeFromSuperview];
}


@end
