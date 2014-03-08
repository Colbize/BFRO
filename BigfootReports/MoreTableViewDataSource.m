//
//  MoreTableViewDataSource.m
//  BigfootReports
//
//  Created by Colby Reineke on 1/26/14.
//  Copyright (c) 2014 Colby Reineke. All rights reserved.
//

#import "MoreTableViewDataSource.h"

int count;

@implementation MoreTableViewDataSource
@synthesize originalDataSource;

- (MoreTableViewDataSource *) initWithDataSource:(id<UITableViewDataSource>) dataSource
{
    self = [super init];
    if (self)
    {
        self.originalDataSource = dataSource;
        count = 0;
    }
        
    return self;
}

- (void)dealloc
{
    self.originalDataSource = nil;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    return [originalDataSource tableView:table numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    if (count == 0) {
        if (indexPath.row == 0) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(2, 9, 25, 25)];
            imv.image=[UIImage imageNamed:@"help"];
            imv.image =[self imageWithColor:[UIColor whiteColor] withImage:imv.image];
            imv.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:imv];
        } else if (indexPath.row == 1) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(2, 9, 25, 25)];
            imv.image=[UIImage imageNamed:@"camping_tent"];
            imv.image =[self imageWithColor:[UIColor whiteColor] withImage:imv.image];
            imv.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:imv];
        } else if (indexPath.row == 2) {
            UIImageView *imv = [[UIImageView alloc]initWithFrame:CGRectMake(2, 9, 25, 25)];
            imv.image=[UIImage imageNamed:@"cart"];
            imv.image =[self imageWithColor:[UIColor whiteColor] withImage:imv.image];
            imv.contentMode = UIViewContentModeScaleAspectFit;
            [cell.contentView addSubview:imv];
            count = 1;
        }
    }
    
    return cell;
}

# pragma mark - change image color
- (UIImage *)imageWithColor:(UIColor *)color1 withImage:(UIImage *)img
{
    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextClipToMask(context, rect, img.CGImage);
    [color1 setFill];
    CGContextFillRect(context, rect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
