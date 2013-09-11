//
//  MapLocation.h
//  WeatherInformer
//
//  Created by Gavrina Maria on 10.09.13.
//
//

#import <MapKit/MapKit.h>

@interface MapLocation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;


- (id) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates title:(NSString *)paramTitle subTitle:(NSString *)paramSubTitle;

@end
