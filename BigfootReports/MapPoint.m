

#import "MapPoint.h"

@implementation MapPoint

@synthesize coordinate, title;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *)sub
{
    self = [super init];
    if (self) {
        coordinate = c;
        [self setTitle:t];
        [self setSubtitle:sub];

    }
    return self;
}

@end
