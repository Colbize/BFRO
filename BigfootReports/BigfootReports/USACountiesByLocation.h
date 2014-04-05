//
//  USACountiesByLocation.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/18/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Location, ReportsByLocation;

@interface USACountiesByLocation : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSSet *reportsByCounty;
@end

@interface USACountiesByLocation (CoreDataGeneratedAccessors)

- (void)addReportsByCountyObject:(ReportsByLocation *)value;
- (void)removeReportsByCountyObject:(ReportsByLocation *)value;
- (void)addReportsByCounty:(NSSet *)values;
- (void)removeReportsByCounty:(NSSet *)values;

@end
