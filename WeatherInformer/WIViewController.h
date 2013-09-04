//
//  WIViewController.h
//  WeatherInformer
//
//  Created by Mary Gavrina on 8/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface WIViewController : UIViewController <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *goButton;
@property (strong, nonatomic) IBOutlet UIButton *modeButton;

@property (strong, nonatomic) IBOutlet UITextField *latText;
@property (strong, nonatomic) IBOutlet UITextField *longText;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) IBOutlet UILabel *weatherLabel;
@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (strong, nonatomic) IBOutlet UILabel *humidityLabel;
@property (strong, nonatomic) IBOutlet UILabel *windLabel;
@property (strong, nonatomic) IBOutlet UILabel *pressureLabel;


@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)modePressed:(id)sender;

- (void)sendRequestWithLatitude:(double)newLatitude withLongitude:(double)newLongitude;

@end
