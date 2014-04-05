//
//  reportMapViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/7/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface reportMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocation *pointLocation;
@property (weak, nonatomic) NSString *pointName;


@end
