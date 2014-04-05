//
//  MoreTableViewDataSource.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/26/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MoreTableViewDataSource : NSObject <UITableViewDataSource>
{
    id<UITableViewDataSource> originalDataSource;
}

@property (retain) id<UITableViewDataSource> originalDataSource;

-(MoreTableViewDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource;



@end
