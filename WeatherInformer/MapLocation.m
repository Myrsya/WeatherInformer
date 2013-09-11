//
//  MapLocation.m
//  WeatherInformer
//
//  Created by Gavrina Maria on 10.09.13.
//
//

#import "MapLocation.h"

@implementation MapLocation

//CLLocationCoordinate2D coordinate;
@synthesize coordinate, title, subtitle;

- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramSubTitle
{
    self = [super init];
    if (self != nil)
    {
        coordinate = paramCoordinates;
        title = paramTitle;
        subtitle = paramSubTitle;
    }
    return(self);
}

@end
