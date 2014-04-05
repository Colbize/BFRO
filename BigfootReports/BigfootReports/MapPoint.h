

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface MapPoint : NSObject <MKAnnotation>

// A new designated initializer for instances of MapPoint
- (id)initWithCoordinate:(CLLocationCoordinate2D)c title:(NSString *)t subtitle:(NSString *)sub;

// This is a required property from MKAnnotation
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

// This is an optional property from MKAnnotation
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, strong) NSString *classID;

@end
