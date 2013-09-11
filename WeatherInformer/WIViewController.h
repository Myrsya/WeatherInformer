//
//  WIViewController.h
//  WeatherInformer
//
//  Created by Mary Gavrina on 8/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
//#import <QuartzCore/QuartzCore.h>
#import "MapLocation.h"

@interface WIViewController : UIViewController
<CLLocationManagerDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet UIButton *geoButton;

@property (strong, nonatomic) IBOutlet UIView *conditionsView;
@property (strong, nonatomic) IBOutlet UIView *forecastView;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (strong, nonatomic) IBOutlet UITextField *latText;
@property (strong, nonatomic) IBOutlet UITextField *longText;
@property (strong, nonatomic) IBOutlet UIImageView *imageWeather;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *weatherLabel;
@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLabel;
@property (strong, nonatomic) IBOutlet UILabel *pressureLabel;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *forecastDay;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *forecastWeatherImage;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *forecastTemp;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *forecastHumid;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *forecastWind;

@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)geoPressed:(id)sender;
- (IBAction)backgroundTap:(id)sender;

- (void)sendRequestForecastWithLatitude:(double)newLatitude withLongitude:(double)newLongitude;
- (void)sendRequestWithLatitude:(double)newLatitude withLongitude:(double)newLongitude;

@end
