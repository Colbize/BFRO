//
//  customBarButtonItem.m
//  BigfootReports
//
//  Created by Colby Reineke on 2/10/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "customBarButtonItem.h"

@implementation customBarButtonItem
@synthesize object;

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action withObject:(id)obj
{
    if (self = [super initWithTitle:title style:style target:target action:action]) {
        object = obj;
    }
    return self;
}

@end
