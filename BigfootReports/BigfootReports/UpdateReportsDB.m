//
//  UpdateReportsDB.m
//  BFRO
//
//  Created by Colby Reineke on 2/22/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "UpdateReportsDB.h"
#import "Location.h"
#import <AFHTTPRequestOperationManager.h>
#import <RXMLElement.h>
#import "ReportsByLocation.h"
#import "USACountiesByLocation.h"

@implementation UpdateReportsDB
{
    NSMutableDictionary *newReportsArray;
    AFHTTPRequestOperationManager *manager;
    bool cancelRequestYN;
}

- (id)init
{
    self = [super init];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(requestToCancel)
                                                     name:@"requestToCancel"
                                                   object:nil];
        cancelRequestYN = NO;
        
    }
    return self;
}

- (void)connectToSite
{
    // Gather all the new reports from the recent reports page
    manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", nil];
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    [manager GET:@"http://www.bfro.net/app/NewReportsXml.aspx"
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedUpdateFromReportsDBNoty"
                                                                 object:@"Connected!"];
             if (cancelRequestYN == NO)
                 [self performSelector:@selector(willStartSearching:) withObject:responseObject afterDelay:0.5];
             
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (cancelRequestYN == NO) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                                object:error.localizedDescription];
        }
        return;
    }];

}

- (void)willStartSearching:(NSData *)data
{
    if (cancelRequestYN == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedUpdateFromReportsDBNoty"
                                                        object:@"Searching for New Reports..."];

        [self performSelector:@selector(didStartsearching:) withObject:data afterDelay:0.5];
    } else {
        return;
    }
}


- (void)didStartsearching:(NSData *)data
{
    if (cancelRequestYN == NO) {
        newReportsArray = [[NSMutableDictionary alloc] init];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"ReportsByLocation"
                                                  inManagedObjectContext:[BFROStore sharedStore].context];
        [fetchRequest setEntity:entity];
        
         RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
        [rootXML iterate:@"report-location" usingBlock: ^(RXMLElement *report) {
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(reportID == %@)", [report child:@"id"].text];
            [fetchRequest setPredicate:predicate];
            
            NSError *error = nil;
            NSUInteger count = [[BFROStore sharedStore].context countForFetchRequest:fetchRequest
                                                                    error:&error];
            if (!error) {
                if (count == 0) {
                    [newReportsArray setObject:[report child:@"id"].text forKey:[report child:@"id"].text];
                }
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                                    object:error.localizedDescription];
                return;
            }
        }];
        
        if (newReportsArray.allKeys.count > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedUpdateFromReportsDBNoty"
                                                                object:[NSString stringWithFormat:@"Found: %lu New Reports...", (unsigned long)newReportsArray.allKeys.count]];
            [self performSelector:@selector(willProcessNewReports:) withObject:data afterDelay:0.5];
        } else  if (cancelRequestYN == NO) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                                object:@"No New Reports"];
            return;
        } else {
            return;
        }
    } else {
        return;
    }
}

- (void)willProcessNewReports:(NSData *)data
{
    if (cancelRequestYN == NO) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receivedUpdateFromReportsDBNoty"
                                                            object:@"Processing New Reports..."];
        [self performSelector:@selector(didProcessNewReports:) withObject:data afterDelay:0.5];
    } else {
        return;
    }

}

- (void)didProcessNewReports:(NSData *)data
{
    __block bool errorOccuredYN;
    errorOccuredYN = NO;
    if (cancelRequestYN == NO) {
        // for each reprot get the report details
        for (NSString *reportID in newReportsArray) {
            if (errorOccuredYN == NO && cancelRequestYN == NO) {
                RXMLElement *rootXML = [RXMLElement elementFromXMLData:data];
                [rootXML iterate:@"report-location" usingBlock: ^(RXMLElement *report) {
                    if ([[report child:@"id"].text isEqual:reportID]) {
                        ReportsByLocation *newReport = [NSEntityDescription insertNewObjectForEntityForName:@"ReportsByLocation"
                                                                                     inManagedObjectContext:[[BFROStore sharedStore] context]];
                        if ([report child:@"id"].text)
                            [newReport setReportID:[report child:@"id"].text];
                        
                        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
                        [dateFormat setDateFormat:@"yyyy-dd-mm"];
                        
                        //date of sighting
                        NSString *sightingsDateString = [[[report child:@"incident-date"].text componentsSeparatedByString:@"T"] firstObject];
                        if ([dateFormat dateFromString:sightingsDateString])
                            [newReport setDateOfSighting:[dateFormat dateFromString:sightingsDateString]];
                        
                        //Witness submitted
                        NSString *witnessDateString = [[[report child:@"published-date"].text componentsSeparatedByString:@"T"] firstObject];
                        if (witnessDateString)
                            [newReport setWitnessSubmitted:[dateFormat dateFromString:witnessDateString]];
                        
                        if ([report child:@"id"].text)
                            [newReport setLink:[NSString stringWithFormat:@"http://www.bfro.net/GDB/show_report.asp?id=%@",[report child:@"id"].text]];
                        
                        if ([report child:@"class"].text)
                            [newReport setClassSighting:[report child:@"class"].text];
                        
                        if ([report child:@"title"].text)
                            [newReport setShortDesc:[report child:@"title"].text];
                        
                        if ([report child:@"center-lat"].text)
                            [newReport setLatitude:[report child:@"center-lat"].text];
                        
                        if ([report child:@"center-long"].text)
                            [newReport setLongitude:[report child:@"center-long"].text];

                        [NSThread sleepForTimeInterval:0.1f];
                        
                        NSError *error = nil;
                        NSString *fullReportHTML = nil;
                        NSString *url = [[NSString stringWithFormat:@"http://www.bfro.net/GDB/show_report.asp?id=%@",[report child:@"id"].text] stringByAppendingString:@"&PrinterFriendly=True"];
                        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:0 timeoutInterval:5];
                        NSURLResponse *response = nil;
                        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                        fullReportHTML = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                        
                        if (fullReportHTML.length > 0) {
                            [newReport setReportHTML:fullReportHTML];
                        } else if (error) {
                            errorOccuredYN = YES;
                            return;
                        } else {
                            errorOccuredYN = YES;
                            return;
                        }
                        
                        // for USA
                        if ([[report child:@"country"].text.lowercaseString isEqualToString:@"us"]) {
                            USACountiesByLocation *county = [self findReportCountyByState:[report child:@"state"].text
                                                                                 byCounty:[report child:@"county"].text];
                            [county addReportsByCountyObject:newReport];
                        } else if ([[report child:@"country"].text.lowercaseString isEqualToString:@"canada"]) { // for Canada
                            Location *canada = [self findLocation:[report child:@"state"].text
                                                        byCountry:@"Canada"];
                            [canada addReportsByLocationObject:newReport];
                        } else if ([[report child:@"country"].text.lowercaseString isEqualToString:@"international location"]) {
                            Location *international = [self findLocation:[report child:@"state"].text
                                                        byCountry:@"International"];
                            [international addReportsByLocationObject:newReport];
                        } else {
                            errorOccuredYN = YES;
                        }
                    }
                }];
            } else {
                break;
            }
        }
        
        if (errorOccuredYN == YES) {
            [[[BFROStore sharedStore] context] rollback];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                                object:@"An Error Has Occured."];
            return;

        }
        
        if (cancelRequestYN == YES) {
            return;
        }
        
        NSError *saveError;
        if (![[[BFROStore sharedStore] context] save:&saveError]) {
            [[[BFROStore sharedStore] context] rollback];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                                object:@"An Error Has Occured."];
             NSLog(@"Save Error: %@", saveError);
            return;
        }
             
        NSMutableDictionary *newReports = [[[NSUserDefaults standardUserDefaults] objectForKey:@"RecentlyAdded"] mutableCopy];
        [newReports addEntriesFromDictionary:newReportsArray];
        [[NSUserDefaults standardUserDefaults] setObject:newReports forKey:@"RecentlyAdded"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                            object:[NSString stringWithFormat:@"%lu New Reports Added", (unsigned long)newReportsArray.allKeys.count]];
    } else {
        return;
    }
}

- (USACountiesByLocation *)findReportCountyByState:(NSString *)state byCounty:(NSString *)county
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"USACountiesByLocation"
                                        inManagedObjectContext:[BFROStore sharedStore].context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(name = %@) AND (location.name = %@)", county, state]];
    
    // Check to see if the county even exists if it does return it, if it doesn't added it.
    NSArray *fetchedCounty = [[[BFROStore sharedStore] context] executeFetchRequest:fetchRequest error:nil];
    if (fetchedCounty.count > 0 ) {
        return [fetchedCounty lastObject];
    } else {
        // Get the state associated state
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Location"
                                            inManagedObjectContext:[BFROStore sharedStore].context]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(name = %@)", state]];
        
        NSArray *fetchedState = [[[BFROStore sharedStore] context] executeFetchRequest:fetchRequest error:nil];
        
        // Create a new County
        USACountiesByLocation *newCounty = [NSEntityDescription insertNewObjectForEntityForName:@"USACountiesByLocation"
                                                                        inManagedObjectContext:[[BFROStore sharedStore] context]];
        newCounty.name = county;
        newCounty.link = nil;
        [[fetchedState lastObject] addCountyByLocationObject:newCounty];
        return newCounty;
    }
}

- (Location *)findLocation:(NSString *)loc byCountry:(NSString *)country
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Location"
                                        inManagedObjectContext:[BFROStore sharedStore].context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(name = %@) AND (country = %@)", loc, country]];
    
    // Check to see if the location even exists if it does return it, if it doesn't added it.
    NSArray *fetchedLocation = [[[BFROStore sharedStore] context] executeFetchRequest:fetchRequest error:nil];
    if (fetchedLocation.count > 0 ) {
        return [fetchedLocation lastObject];
    } else {
        // Create a new location
        Location *newLocation = [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                                                         inManagedObjectContext:[[BFROStore sharedStore] context]];
        newLocation.name = loc;
        newLocation.link = nil;
        newLocation.country = country;
        return newLocation;
    }
}

- (void)requestToCancel
{
    cancelRequestYN = YES;
    [manager.operationQueue cancelAllOperations];
    [[[BFROStore sharedStore] context] rollback];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sendToastNoty"
                                                        object:@"Canceled!"];
    return;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"requestToCancel"  object:nil];
}

@end
