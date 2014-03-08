//
//  customBarButtonItem.h
//  BigfootReports
//
//  Created by Colby Reineke on 2/10/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface customBarButtonItem : UIBarButtonItem
{
    id object;
}

@property (nonatomic, retain) id object;

- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action withObject:(id)obj;

@end
