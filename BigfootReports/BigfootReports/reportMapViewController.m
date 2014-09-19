//
//  reportMapViewController.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/7/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "reportMapViewController.h"
#import "MapPoint.h"

@interface reportMapViewController ()
{
    CLLocationManager *locationManager;
    int mType;
    bool findMeYN;
}

@end

@implementation reportMapViewController
@synthesize map, pointLocation, pointName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
    }
    return self;
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
        region = MKCoordinateRegionMakeWithDistance(coord, 500000, 500000);
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
    NSLog(@"Could not find location: %@", error);
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:MKUserLocation.class]) {
        return nil;
    }
    
    MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation   reuseIdentifier:@"current"];
    
//    UIButton *goToObjectButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    
//    [goToObjectButton addTarget:self action:@selector(goToObjectClick:)  forControlEvents:UIControlEventTouchUpInside];
    
    MyPin.pinColor = MKPinAnnotationColorRed;
//    MyPin.rightCalloutAccessoryView = goToObjectButton;
    MyPin.draggable = NO;
    MyPin.highlighted = NO;
    MyPin.animatesDrop=YES;
    MyPin.canShowCallout = YES;
    
    return MyPin;
}

#pragma mark - view load methods
- (void)viewWillDisappear:(BOOL)animated
{
    map.mapType = MKMapTypeSatellite;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    // GO TO layers BUTTON
    UIButton *layers = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    layers.frame = CGRectMake(0, 0, 38, 44);
    [layers setImage:[UIImage imageNamed:@"layers"] forState:UIControlStateNormal];
    [layers addTarget:self action:@selector(changeLayer) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *layerItem = [[UIBarButtonItem alloc] initWithCustomView:layers];
    
    [layerItem setTintColor:self.view.tintColor];
    
    // Find Me button
    UIButton *nearMe = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nearMe.frame = CGRectMake(0, 0, 38, 44);
    [nearMe setImage:[UIImage imageNamed:@"near_me"] forState:UIControlStateNormal];
    [nearMe addTarget:self action:@selector(findMe) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *nearMeItem = [[UIBarButtonItem alloc] initWithCustomView:nearMe];
    
    [nearMeItem setTintColor:self.view.tintColor];
    
    // Get Directions button
    UIButton *dir = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    dir.frame = CGRectMake(0, 0, 38, 44);
    [dir setImage:[UIImage imageNamed:@"directions"] forState:UIControlStateNormal];
    [dir addTarget:self action:@selector(getDirections) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *dirItem = [[UIBarButtonItem alloc] initWithCustomView:dir];
    
    [nearMeItem setTintColor:self.view.tintColor];
    

    // SET NAV BUTTONS
    NSArray *rightItems = [[NSArray alloc] initWithObjects: nearMeItem, dirItem, layerItem, nil];
    [[self navigationItem] setRightBarButtonItems:rightItems];
    
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    map.mapType = MKMapTypeStandard;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;

    CLLocationCoordinate2D coord = [pointLocation coordinate];
    MKCoordinateRegion region;
    // Create an instance of MapPoint with the current data
    MapPoint *mp = [[MapPoint alloc] initWithCoordinate:coord
                                                  title:[NSString stringWithFormat:@"Location of ReportID: %@", pointName]
                                                    subtitle:nil];
    // Add it to the map view
    [map addAnnotation:mp];
    region = MKCoordinateRegionMakeWithDistance(coord, 500000, 500000);
    [map setRegion:region animated:YES];
}

#pragma mark - get Direcitons
-(void)getDirections
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = [pointLocation coordinate];
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:[NSString stringWithFormat:@"ReportID: %@", pointName]];
        
        // Set the directions mode to "Walking"
        // Can use MKLaunchOptionsDirectionsModeDriving instead
        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        // Get the "Current User Location" MKMapItem
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        // Pass the current location and destination map items to the Maps app
        // Set the direction mode in the launchOptions dictionary
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }
}

#pragma mark - change layer
- (void)changeLayer {
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
- (void)findMe
{
    [map setShowsUserLocation:YES];
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        findMeYN = YES;
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [self.map makeToast:@"Location Service Not Enabled. To Enable go to iPhone Settings > Privacy > Location Services > BFRO to re-enable" duration:7.0 position:@"center"];
    }
    
    [locationManager startUpdatingLocation];
    findMeYN = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
