//
//  SightingsMapViewController.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/6/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface SightingsMapViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@property (strong, nonatomic) UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *showReports;
- (IBAction)showReports:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *layers;
- (IBAction)changeLayer:(id)sender;

@property (strong, nonatomic) IBOutlet MKMapView *map;

- (IBAction)findMe:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *findMe;

@property (weak, nonatomic) IBOutlet UILabel *whiteLabel;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
- (IBAction)infoButton:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *eraseAll;
- (IBAction)eraseAll:(id)sender;

// Legend Info
@property (strong, nonatomic) IBOutlet UIView *legendView;
@property (weak, nonatomic) IBOutlet UILabel *redColor;
@property (weak, nonatomic) IBOutlet UILabel *purpleColor;
@property (weak, nonatomic) IBOutlet UILabel *greenColor;
@property (weak, nonatomic) IBOutlet UIView *theLegendView;


@end
