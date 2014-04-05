//
//  Location.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/18/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ReportsByLocation, USACountiesByLocation;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * country;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *countyByLocation;
@property (nonatomic, retain) NSSet *reportsByLocation;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addCountyByLocationObject:(USACountiesByLocation *)value;
- (void)removeCountyByLocationObject:(USACountiesByLocation *)value;
- (void)addCountyByLocation:(NSSet *)values;
- (void)removeCountyByLocation:(NSSet *)values;

- (void)addReportsByLocationObject:(ReportsByLocation *)value;
- (void)removeReportsByLocationObject:(ReportsByLocation *)value;
- (void)addReportsByLocation:(NSSet *)values;
- (void)removeReportsByLocation:(NSSet *)values;

@end
