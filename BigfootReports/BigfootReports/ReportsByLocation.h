//
//  ReportsByLocation.h
//  
//
//  Created by Colby Reineke on 1/19/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, USACountiesByLocation;

@interface ReportsByLocation : NSManagedObject

@property (nonatomic, retain) NSString * classSighting;
@property (nonatomic, retain) NSDate * dateOfSighting;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * reportHTML;
@property (nonatomic, retain) NSString * reportID;
@property (nonatomic, retain) NSString * shortDesc;
@property (nonatomic, retain) NSDate * witnessSubmitted;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) Location *reportsByLocation;
@property (nonatomic, retain) USACountiesByLocation *usaCountyReports;

@end
