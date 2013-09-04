//
//  WIViewController.m
//  WeatherInformer
//
//  Created by Mary Gavrina on 8/29/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "WIViewController.h"

@implementation WIViewController
{
    double latitude, longtitude;
    BOOL manualMod;
}
@synthesize modeButton;
@synthesize weatherLabel;
@synthesize temperatureLabel;
@synthesize humidityLabel;
@synthesize windLabel;
@synthesize pressureLabel;

@synthesize goButton, latText, longText, locationLabel, locationManager;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CLLocationManager locationServicesEnabled])
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        
        self.latText.text = [NSString stringWithFormat:@"%1.2f", latitude];
        self.longText.text = [NSString stringWithFormat:@"%1.2f", longtitude];
    }
    else
    {
        NSLog(@"Nocation services are not enabled");
    }
}

- (void)viewDidUnload
{
    [self setGoButton:nil];
    [self setLatText:nil];
    [self setLongText:nil];
    [self setLocationLabel:nil];
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    [self setWeatherLabel:nil];
    [self setTemperatureLabel:nil];
    [self setHumidityLabel:nil];
    [self setWindLabel:nil];
    [self setPressureLabel:nil];
    [self setModeButton:nil];
    [super viewDidUnload];
}

#pragma mark - Other

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    latitude = newLocation.coordinate.latitude;
    longtitude = newLocation.coordinate.longitude;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"location error: %@", [error localizedDescription]);
}

- (IBAction)buttonPressed:(id)sender
{
    self.latText.text = [NSString stringWithFormat:@"%1.2f", latitude];
    self.longText.text = [NSString stringWithFormat:@"%1.2f", longtitude];
    
    [self sendRequestWithLatitude:[self.latText.text doubleValue] withLongitude:[self.longText.text doubleValue]];
}

- (IBAction)modePressed:(id)sender 
{
    //auto -> manual
    if (!manualMod)
    {
        manualMod = YES;
        self.modeButton.titleLabel.text = @"MANUAL";
        self.latText.enabled = YES;
        self.longText.enabled = YES;
    }
    // manual -> auto
    else
    {
        manualMod = NO;
        self.modeButton.titleLabel.text = @"AUTO";
        self.latText.enabled = NO;
        self.longText.enabled = NO;
    }
}

- (void)sendRequestWithLatitude:(double)newLatitude withLongitude:(double)newLongitude
{
    NSString *weatherString = @"http://api.wunderground.com/api/";
    //apikey
    weatherString = [weatherString stringByAppendingString:@"8fb05173dafb9465/"];
    //features
    weatherString = [weatherString stringByAppendingString:@"conditions/"];
    //settings
    weatherString = [weatherString stringByAppendingString:@"lang:RU/q/"];
    //latitude & longitude
    NSString *quary = [NSString stringWithFormat:@"%f,%f", newLatitude, newLongitude];
    weatherString = [weatherString stringByAppendingString:quary];
    //format
    weatherString = [weatherString stringByAppendingString:@".json"];
    
    NSURL *weatherURL = [NSURL URLWithString:weatherString];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:weatherURL];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if (error)
    {
        NSLog(@"Request error: %@", [error localizedDescription]);
    }
    else
    {
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", result);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        NSDictionary *display_location = [[json objectForKey:@"current_observation"] objectForKey:@"display_location"];
        
        self.locationLabel.text = [NSString stringWithFormat:@"%@, %@",
                                   [display_location objectForKey:@"city"],
                                   [display_location objectForKey:@"country"]];
        self.weatherLabel.text = [[json objectForKey:@"current_observation"] objectForKey:@"weather"];
        self.temperatureLabel.text = [NSString stringWithFormat:@"%@ C",
                                      [[json objectForKey:@"current_observation"] objectForKey:@"temp_c"]];
        self.humidityLabel.text = [[json objectForKey:@"current_observation"] objectForKey:@"relative_humidity"];
        self.windLabel.text = [NSString stringWithFormat:@"%@, %@ км/ч",
                                 [[json objectForKey:@"current_observation"] objectForKey:@"wind_dir"],
                                 [[json objectForKey:@"current_observation"] objectForKey:@"wind_kph"]];
        float pressureThor =[[[json objectForKey:@"current_observation"] objectForKey:@"pressure_mb"] floatValue] * 0.75006;
        self.pressureLabel.text = [NSString stringWithFormat:@"%1.2f мм рт ст", pressureThor];
    }
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

@end
