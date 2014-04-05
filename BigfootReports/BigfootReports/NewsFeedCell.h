//
//  NewsFeedCell.h
//  BigfootReports
//
//  Created by Colby Reineke on 1/14/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *tweetDate;
@property (weak, nonatomic) IBOutlet UITextView *tweet;
@property (weak, nonatomic) IBOutlet UILabel *retweeted;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *retweetIcon;
@end
