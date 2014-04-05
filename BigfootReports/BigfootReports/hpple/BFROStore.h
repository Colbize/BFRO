//
//  BFROStore.h
//  BigfootReports
//
//  Created by Colby Reineke on 8/12/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BFROStore : NSObject
@property NSManagedObjectModel *model;
@property NSManagedObjectContext *context;

+ (BFROStore *)sharedStore;

@end
