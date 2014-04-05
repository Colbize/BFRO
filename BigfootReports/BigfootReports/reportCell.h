//
//  reportCell.h
//  BigfootReports
//
//  Created by Colby Reineke on 8/21/13.
//  Copyright (c) 2013 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface reportCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *reportID;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *shortDesc;
@property (weak, nonatomic) IBOutlet UIImageView *containsPicturesYN;
@property (weak, nonatomic) IBOutlet UIImageView *favoritedYN;
@property (weak, nonatomic) IBOutlet UIImageView *read;
@property (weak, nonatomic) IBOutlet UILabel *classID;
@property (weak, nonatomic) IBOutlet UIImageView *hasLocation;

@end
