//
//  UpdateReportsDB.h
//  BFRO
//
//  Created by Colby Reineke on 2/22/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USACountiesByLocation.h"
@interface UpdateReportsDB : NSObject

- (void)connectToSite;
- (USACountiesByLocation *)findReportCountyByState:(NSString *)state byCounty:(NSString *)county;
- (Location *)findLocation:(NSString *)loc byCountry:(NSString *)country;
@end
