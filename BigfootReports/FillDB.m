//
//  FillDB.m
//  BigfootReports
//
//  Created by Colby Reineke on 11/24/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "FillDB.h"
#import "TFHpple.h"
#import "BFROStore.h"
#import "AllArticles.h"
#import "Location.h"
#import "ReportsByLocation.h"
#import "USACountiesByLocation.h"

@implementation FillDB

- (id)init {
    if (self) {
        [self getLocations];
        [self getAllArticles];
        //[self deleteEntries];
        
    }
    
    return self;
}

- (void)getLocations {
    NSURL *url = [NSURL URLWithString:@"http://www.bfro.net/GDB/default.asp"];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];

    NSMutableSet *AllReportsByCanadaSet = [[NSMutableSet alloc] init];
    NSMutableSet *AllReportsByIntSet = [[NSMutableSet alloc] init];

    
    // 2
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    for (int i = 5; i <= 12; i++) {
        //NSLog(@"%d", i);
        // /html/body/table/tbody/tr/td[3]/table/tbody*
        NSString *xpathquery = [NSString stringWithFormat:@"//table[%d]/tr/*", i];
        NSArray *nodes = [parser searchWithXPathQuery:xpathquery];
        
        // 4
        for (TFHppleElement *element in nodes) {
            //NSLog(@"%@", element.tagName);

            for (TFHppleElement *child in element.children) {
                // United Locations
                if (i == 5 || i == 6) {
                    if (child.firstChild.text) {
                        NSLog(@"United States: %@", child.firstChild.text);//, [@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]);

                        Location *Location = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                    inManagedObjectContext:[[BFROStore sharedStore] context]];
                        [Location setName:child.firstChild.text];
                        [Location setLink:[@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]];
                        [Location setCountry:@"USA"];
                        [self getCountiesByLocationUrl:[@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]
                                          withLocation:Location];
                        
                    }
                }

                // Canada
                if (i == 7 || i == 8 || i == 9) {
                    if (child.firstChild.text) {
                        NSLog(@"CANADA: %@", child.firstChild.text);
                        //NSLog(@"%@", [@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]);
                        Location *canada = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                     inManagedObjectContext:[[BFROStore sharedStore] context]];
                        [canada setName:child.firstChild.text];
                        [canada setLink:[@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]];
                        [canada setCountry:@"Canada"];
                        
                        AllReportsByCanadaSet = [self getReportsByCountyUrl:[@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]
                                         withCounty:nil withCanada:canada withInt:nil];
                        
                        [canada setReportsByLocation:AllReportsByCanadaSet];
                        NSError *error;
                        if (![[[BFROStore sharedStore] context] save:&error]) {
                            NSLog(@"%@", error);
                        }

                    }
                }
                // International
                if (i == 10 || i == 11 || i == 12) {
                    if (child.firstChild.text) {
                        NSLog(@"INT: %@", child.firstChild.text);
                        //NSLog(@"%@", [@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]);
                        Location *inter = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                     inManagedObjectContext:[[BFROStore sharedStore] context]];
                        [inter setName:child.firstChild.text];
                        [inter setLink:[@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]];
                        [inter setCountry:@"International"];
                        
                        AllReportsByIntSet = [self getReportsByCountyUrl:[@"http://www.bfro.net" stringByAppendingString:[child.firstChild objectForKey:@"href"]]
                                                                 withCounty:nil withCanada:nil withInt:inter];
                        
                        [inter setReportsByLocation:AllReportsByIntSet];
                        NSError *error;
                        if (![[[BFROStore sharedStore] context] save:&error]) {
                            NSLog(@"%@", error);
                        }

                    }
                }
            }
        }
    }
}

- (void)getAllArticles
{
    
    NSString *county = @"";
    NSString *link = @"";
    NSString *publication = @"";
    NSDate *publicationDate = nil;
    NSString *Location = @"";
    NSString *title = @"";
    NSString *articleData = nil;
    AllArticles *allArticle;
    
    NSURL *url = [NSURL URLWithString:@"http://www.bfro.net/GDB/newart.asp"];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *xpathquery = [NSString stringWithFormat:@"//td[@class='onrow' or @class='altrow']"];
    NSArray *nodes = [parser searchWithXPathQuery:xpathquery];
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd-MM-yyyy"];
    
    int count = 0;
    for (TFHppleElement *element in nodes) {
        for (TFHppleElement *child in element.children) {
            NSDate *date = [dateFormat dateFromString:child.content];
            
            if ([child objectForKey:@"href"]) {
                link = [@"http://www.bfro.net/GDB/" stringByAppendingString:[child objectForKey:@"href"]];
             }

            if (child.firstTextChild.content && !date) {
                if (count == 0) {
                    title = [[child.firstTextChild.content stringByReplacingOccurrencesOfString:@"" withString:@"'"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    count++;
                }
            }
            if (child.content && !date) {
                if (count == 1) {
                    publication = [child.content stringByReplacingOccurrencesOfString:@"" withString:@"'"];
                } else if (count == 2) {
                    Location = [child.content stringByReplacingOccurrencesOfString:@"" withString:@"'"];
                } else if (count == 3) {
                    county = [child.content stringByReplacingOccurrencesOfString:@"" withString:@"'"];
                }
                count++;
                
            } else if (date) {
                //NSLog(@"%d", count);
                
                if (count != 0) {
                    allArticle = [NSEntityDescription insertNewObjectForEntityForName:@"AllArticles"
                                                                 inManagedObjectContext:[[BFROStore sharedStore] context]];
                    
                    [allArticle setPublicationDate:publicationDate];
                    [allArticle setLink:link];
                    [allArticle setTitle:title];
                    [allArticle setPublication:publication];
                    [allArticle setCounty:county];
                    
                    NSURL *url = [NSURL URLWithString:link];
                    NSError *error;
                    articleData = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
                    if (error) {
                        NSLog(@"ERROR!: %@", error);
                    }
                    
                    [allArticle setArticleHTML:articleData];
                    
                    NSLog(@"%@", title);
                    
                    // SLEEP FOR 5 Secs
                    //[NSThread sleepForTimeInterval:0.3f];
                    
                    NSError *error1;
                    if (![[[BFROStore sharedStore] context] save:&error1]) {
                        NSLog(@"%@", error1);
                    }
                }
                
                publicationDate = date;

                county = @"";
                link = @"";
                publication = @"";
                Location = @"";
                title = @"";
                articleData = nil;
                
                count = 0;
            }

            }
        }
}

- (void)getCountiesByLocationUrl:(NSString *)u withLocation:(Location *)Location
{
    NSString *nameString;
    NSString *urlString;
    NSSet *AllReportsByCountySet = [[NSSet alloc] init];
    
    NSURL *url = [NSURL URLWithString:u];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    NSMutableSet *countiesSet = [[NSMutableSet alloc] init];
    for (int i = 7; i <= 8; i++) {
        NSString *xpathquery = [NSString stringWithFormat:@"//table[%d]/tr/td/*", i];
        NSArray *nodes = [parser searchWithXPathQuery:xpathquery];
        for (TFHppleElement *element in nodes) {
            for (TFHppleElement *child in element.children) {
                if (child.text) {
                    nameString = child.text;
                    NSLog(@"%@", nameString);
                    urlString = [[@"http://www.bfro.net/GDB/" stringByAppendingString:[child objectForKey:@"href"]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    USACountiesByLocation *counties = [NSEntityDescription insertNewObjectForEntityForName:@"USACountiesByLocation"
                                                                 inManagedObjectContext:[[BFROStore sharedStore] context]];
                    counties.name = nameString;
                    counties.link = urlString;
                    counties.location = Location;
                    [countiesSet addObject:counties];
                    AllReportsByCountySet = [[self getReportsByCountyUrl:urlString withCounty:counties withCanada:nil withInt:nil] mutableCopy];
                    
                    [counties setReportsByCounty:AllReportsByCountySet];
                    
                    NSError *error;
                    if (![[[BFROStore sharedStore] context] save:&error]) {
                        NSLog(@"%@", error);
                    }
                }
            }
        }
    }
    [Location setCountyByLocation:countiesSet];
    
    NSError *error;
    if (![[[BFROStore sharedStore] context] save:&error]) {
        NSLog(@"%@", error);
    }
}

- (NSMutableSet *)getReportsByCountyUrl:(NSString *)u withCounty:(USACountiesByLocation *)county withCanada:(Location *)canada withInt:(Location *)inter
{
    NSDate *witnessSubmited;
    NSString *dateOfSighting = @"";
    NSString *reportURL = @"";
    NSString *classType = @"";
    NSString *shortDesc = @"";
    NSString *fullReportHTML = @"";
    NSString *reportID = @"";
    ReportsByLocation *LocationReports;
    ReportsByLocation *canadaReports;
    ReportsByLocation *interReports;
    
    NSMutableSet *AllReportsByCountySet = [[NSMutableSet alloc] init];
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMMM yyyy"];
    
    //dateOfSighting = [dateFormat dateFromString:dateStr];
    
    NSURL *url = [NSURL URLWithString:u];
    NSData *htmlData = [NSData dataWithContentsOfURL:url];
    
    TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
    
    NSString *xpathquery2 = [NSString stringWithFormat:@"//ul[1]/li/span"];
    
    NSArray *nodes2 = [parser searchWithXPathQuery:xpathquery2];
    
    for (TFHppleElement *element in nodes2) {
        for (TFHppleElement *child in element.children) {
            if (child.content) {
                if ([[child.content substringToIndex:2] isEqualToString:@"(C"]) {
                    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"()"];
                    classType = [[child.content componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
                }
                // short desc
                if ([[child.content substringToIndex:2] isEqualToString:@" -"]) {
                    shortDesc = [child.content substringFromIndex:3];
                }

            }
            if ( [[[child childrenWithTagName:@"a"] lastObject] text]) {
                dateOfSighting = [[[child childrenWithTagName:@"a"] lastObject] text];
            }
            
            if ([child.firstChild objectForKey:@"href"]) {
                reportURL = [@"http://www.bfro.net/GDB/" stringByAppendingString:[child.firstChild objectForKey:@"href"]];
                NSURL *url = [NSURL URLWithString:[reportURL stringByAppendingString:@"&PrinterFriendly=True"]];
                NSError *error;
                fullReportHTML = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
                
                if (error) {
                    NSLog(@"%@", error);
                }
                // SLEEP
                //[NSThread sleepForTimeInterval:0.3f];
                
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MMMM-dd-yyyy"];
                
                NSData* htmlData = [fullReportHTML dataUsingEncoding:NSUTF8StringEncoding];
                TFHpple *parser = [TFHpple hppleWithHTMLData:htmlData];
                NSString *xpathquery = [NSString stringWithFormat:@"/html/body/span[4]"];
                NSArray *nodes = [parser searchWithXPathQuery:xpathquery];
                
                for (TFHppleElement *element in nodes) {
                    for (TFHppleElement *child in element.children) {
                        NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@",.  "];
                        NSString *stringManipulate = [[child.content componentsSeparatedByCharactersInSet:charSet] componentsJoinedByString:@""];
                        stringManipulate = [stringManipulate lowercaseString];
                        stringManipulate = [[stringManipulate componentsSeparatedByString:@"on"] objectAtIndex:1];
                        
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@" " withString:@" "];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"monday" withString:@""];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"tuesday" withString:@""];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"wednesday" withString:@""];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"thursday" withString:@""];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"friday" withString:@""];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"saturday" withString:@""];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@"sunday" withString:@""];


                        stringManipulate = [stringManipulate stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        stringManipulate = [stringManipulate stringByReplacingOccurrencesOfString:@" " withString:@"-"];
                        witnessSubmited  = [format dateFromString:stringManipulate];
                    }
                }
                
                if (error) {
                    NSLog(@"ERROR!: %@", error);
                }
            }
            
            if (![reportURL isEqualToString:@""] && ![classType isEqualToString:@""] && ![shortDesc isEqualToString:@""]
                && ![fullReportHTML isEqualToString:@""]) {
                
                reportID = [reportURL stringByReplacingOccurrencesOfString:@"http://www.bfro.net/GDB/show_report.asp?id=" withString:@""];
                
                dateOfSighting = [dateOfSighting.lowercaseString stringByReplacingOccurrencesOfString:@"fall" withString:@"september"];
                dateOfSighting = [dateOfSighting.lowercaseString stringByReplacingOccurrencesOfString:@"winter" withString:@"december"];
                dateOfSighting = [dateOfSighting.lowercaseString stringByReplacingOccurrencesOfString:@"summer" withString:@"june"];
                dateOfSighting = [dateOfSighting.lowercaseString stringByReplacingOccurrencesOfString:@"spring" withString:@"march"];
                dateOfSighting = [dateOfSighting.lowercaseString stringByReplacingOccurrencesOfString:@"-" withString:@" "];
                dateOfSighting = [dateOfSighting.lowercaseString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                dateOfSighting = [[dateOfSighting.lowercaseString componentsSeparatedByString:@"or"] objectAtIndex:0];


                if (canada) {
                    canadaReports = [NSEntityDescription insertNewObjectForEntityForName:@"ReportsByLocation"
                                                                 inManagedObjectContext:[[BFROStore sharedStore] context]];
                    [canadaReports setReportID:reportID];
                    
                    //date of sighting
                    [canadaReports setDateOfSighting:[dateFormat dateFromString:dateOfSighting]];
    
                    
                    //Witness submitted
                    [canadaReports setWitnessSubmitted:witnessSubmited];

                    [canadaReports setLink:reportURL];
                    [canadaReports setClassSighting:classType];
                    [canadaReports setShortDesc:shortDesc];
                    [canadaReports setReportHTML:fullReportHTML];
                    [canadaReports setReportsByLocation:canada];
                    
                    [AllReportsByCountySet addObject:canadaReports];
                    
                } else if (inter) {
                    
                    interReports = [NSEntityDescription insertNewObjectForEntityForName:@"ReportsByLocation"
                                                                 inManagedObjectContext:[[BFROStore sharedStore] context]];
                    
                    [interReports setReportID:reportID];
                    [interReports setLink:reportURL];
                    
                    //date of sighting
                    [interReports setDateOfSighting:[dateFormat dateFromString:dateOfSighting]];

                    
                    //Witness submitted
                    [interReports setWitnessSubmitted:witnessSubmited];
   
                    [interReports setClassSighting:classType];
                    [interReports setShortDesc:shortDesc];
                    [interReports setReportHTML:fullReportHTML];
                    [interReports setReportsByLocation:inter];
                    
                    [AllReportsByCountySet addObject:interReports];
                    
                } else if (county) {
                // Done parsing add the data here for each report
                LocationReports = [NSEntityDescription insertNewObjectForEntityForName:@"ReportsByLocation"
                                                             inManagedObjectContext:[[BFROStore sharedStore] context]];
                
                [LocationReports setReportID:reportID];
                
                //date of sighting
                [LocationReports setDateOfSighting:[dateFormat dateFromString:dateOfSighting]];
                
                //Witness submitted
                [LocationReports setWitnessSubmitted:witnessSubmited];

                [LocationReports setLink:reportURL];
                [LocationReports setClassSighting:classType];
                [LocationReports setShortDesc:shortDesc];
                [LocationReports setReportHTML:fullReportHTML];
                [LocationReports setUsaCountyReports:county];
                
                [AllReportsByCountySet addObject:LocationReports];
                }
                
                NSError *error;

                if (![[[BFROStore sharedStore] context] save:&error]) {
                    // This is bad
                    NSLog(@"%@", error);
                }
                
                reportID = @"";
                dateOfSighting = @"";
                reportURL = @"";
                classType = @"";
                shortDesc = @"";

            }
        }
    }
    
    return AllReportsByCountySet;
}

- (void)deleteEntries
{
//    NSFetchRequest * allCars = [[NSFetchRequest alloc] init];
//    [allCars setEntity:[NSEntityDescription entityForName:@"AllArticles" inManagedObjectContext:[[BFROStore sharedStore] context]]];
//    [allCars setIncludesPropertyValues:NO]; //only fetch the managedObjectID
//    
//    NSError * error = nil;
//    NSArray * cars = [[[BFROStore sharedStore] context] executeFetchRequest:allCars error:&error];
//    //error handling goes here
//    for (NSManagedObject * car in cars) {
//        [[[BFROStore sharedStore] context] deleteObject:car];
//    }
//    NSError *saveError = nil;
//    [[[BFROStore sharedStore] context] save:&saveError];
//    //more error handling here
}

@end
