//
//  AllArticles.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/18/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AllArticles : NSManagedObject

@property (nonatomic, retain) NSString * articleHTML;
@property (nonatomic, retain) NSString * county;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * publication;
@property (nonatomic, retain) NSDate * publicationDate;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * title;

@end
