//
//  reportCell.m
//  BigfootReports
//
//  Created by Colby Reineke on 8/21/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import "reportCell.h"

@implementation reportCell
@synthesize reportID, classID, shortDesc, location, date, containsPicturesYN, favoritedYN, hasLocation;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
