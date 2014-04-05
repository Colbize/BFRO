//
//  FillDB.h
//  BigfootReports
//
//  Created by Colby Reineke on 11/24/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "USACountiesByLocation.h"
#import "Location.h"

@interface FillDB : UIViewController <UIWebViewDelegate, NSXMLParserDelegate>

- (void)getLocations;
- (void)getAllArticles;
- (void)deleteEntries;

- (void)getCountiesByLocationUrl:(NSString *)u withLocation:(Location *)Location;
- (NSMutableSet *)getReportsByCountyUrl:(NSString *)u withCounty:(USACountiesByLocation *)county withCanada:(Location *)canada withInt:(Location *)inter;

@end
