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
    NSMutableData *responseDataConditions;
    NSMutableData *responseDataForecast;
    NSURLConnection *connectionConditions;
    NSURLConnection *connectionForecast;
    int numberOfRequest;
}

@synthesize geoButton;
@synthesize weatherLabel;
@synthesize temperatureLabel;
@synthesize humidityLabel;
@synthesize windLabel;
@synthesize pressureLabel;
@synthesize forecastDay;
@synthesize forecastWeatherImage;
@synthesize forecastTemp;
@synthesize forecastHumid;
@synthesize forecastWind;

@synthesize goButton, latText, longText, locationLabel, locationManager;


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSArray *)sortArrayByX:(NSArray *)sortingArray
{
    return [sortingArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if ([obj1 frame].origin.x < [obj2 frame].origin.x) return NSOrderedAscending;
        else if ([obj1 frame].origin.x > [obj2 frame].origin.x) return NSOrderedDescending;
        else return NSOrderedSame;
    }];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CLLocationManager locationServicesEnabled] && !([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        [locationManager startUpdatingLocation];
        [self.goButton setEnabled:YES];
        [self.geoButton setEnabled:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:@"Геолокация выключена." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [locationManager stopUpdatingLocation];
        [self.goButton setEnabled:NO];
        [self.geoButton setEnabled:NO];
    }
    self.forecastDay = [self sortArrayByX:self.forecastDay];
    self.forecastWeatherImage = [self sortArrayByX:forecastWeatherImage];
    self.forecastTemp = [self sortArrayByX:self.forecastTemp];
    self.forecastHumid = [self sortArrayByX:self.forecastHumid];
    self.forecastWind = [self sortArrayByX:self.forecastWind];
    
    //button
    //self.goButton.layer.cornerRadius = 10.0f;
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
    [self setGeoButton:nil];
    [self setForecastDay:nil];
    [self setForecastWeatherImage:nil];
    [self setForecastTemp:nil];
    [self setForecastHumid:nil];
    [self setForecastWind:nil];
    [self setImageWeather:nil];
    [self setDateLabel:nil];
    [self setConditionsView:nil];
    [self setForecastView:nil];
    [self setIndicator:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}

#pragma mark - location manage

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    latitude = newLocation.coordinate.latitude;
    longtitude = newLocation.coordinate.longitude;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:@"Невозможно определить местоположение"delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - buttons & keyboard manage

- (IBAction)buttonPressed:(id)sender
{
    if ([self.latText.text length] == 0 && [self.longText.text length] == 0)
    {
        self.latText.text = [NSString stringWithFormat:@"%1.2f", latitude];
        self.longText.text = [NSString stringWithFormat:@"%1.2f", longtitude];
    }
    
    [self.indicator setHidden:NO];
    [self.indicator startAnimating];
    [self.conditionsView setHidden:YES];
    [self.forecastView setHidden:YES];
    numberOfRequest = 0;
       
    [self sendRequestWithLatitude:[self.latText.text doubleValue] withLongitude:[self.longText.text doubleValue]];
    [self sendRequestForecastWithLatitude:[self.latText.text doubleValue] withLongitude:[self.longText.text doubleValue]];
}

- (IBAction)geoPressed:(id)sender
{
    if ([self.latText.text length] != 0 && [self.longText.text length] != 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Заменить введенные координаты на данные GPS?" delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else
    {
        self.latText.text = [NSString stringWithFormat:@"%1.2f", latitude];
        self.longText.text = [NSString stringWithFormat:@"%1.2f", longtitude];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        self.latText.text = [NSString stringWithFormat:@"%1.2f", latitude];
        self.longText.text = [NSString stringWithFormat:@"%1.2f", longtitude];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backgroundTap:(id)sender {
    [self.longText resignFirstResponder];
    [self.latText resignFirstResponder];
}

#pragma mark - format output

-(NSString *)formatTemperature:(NSString *)source
{
    if ([source integerValue] > 0)
        return [NSString stringWithFormat:@"+%@", source];
    else
        return source;
}

- (NSString *)formatWindWithDir:(NSString *)windDir andSpeed:(NSString *)windSpeed
{
    NSString *newDir, *newSpeed;
    //shorten wind dir
    if ([windDir length]> 4)
        newDir= [windDir substringWithRange:NSMakeRange(0, 1)];
    else
        newDir = windDir;
    //convert kph to mps
    newSpeed = [NSString stringWithFormat: @"%1.0f", [windSpeed floatValue] * 1000 / 3600];
    
    return [NSString stringWithFormat:@"%@,\n%@м/с", newDir, newSpeed];
}

- (NSString *)formatHumidity:(NSString *)source
{
    return [NSString stringWithFormat:@"%@%%", source];
}

#pragma mark - requests

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (connection == connectionConditions)
    {
        responseDataConditions = [[NSMutableData alloc] init];
    }
    else
    {
        responseDataForecast = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (connection == connectionConditions)
    {
        [responseDataConditions appendData:data];
    }
    else
    {
        [responseDataForecast appendData:data];
    }
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    if (connection == connectionConditions)
    {
        //NSString *result = [[NSString alloc] initWithData:responseDataConditions encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", result);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseDataConditions options:kNilOptions error:&error];
        if (!error)
        {
            NSDictionary *display_location = [[json objectForKey:@"current_observation"] objectForKey:@"display_location"];
            
            self.locationLabel.text = [NSString stringWithFormat:@"%@",
                                       [display_location objectForKey:@"full"]];
            
            self.dateLabel.text = [[[json objectForKey:@"current_observation"] objectForKey:@"local_time_rfc822"] substringToIndex:26];
            
            self.weatherLabel.text = [[json objectForKey:@"current_observation"] objectForKey:@"weather"];
            
            NSURL *imgURL =[ NSURL URLWithString:[NSString stringWithFormat:@"%@", [[json objectForKey:@"current_observation"] objectForKey:@"icon_url"]]];
            NSData *data = [[NSData alloc]initWithContentsOfURL:imgURL];
            UIImage *image = [[UIImage alloc]initWithData:data];
            [self.imageWeather setImage:image];
            
            self.temperatureLabel.text = [NSString stringWithFormat:@"%@°C",
                                          [self formatTemperature:[[json objectForKey:@"current_observation"] objectForKey:@"temp_c"]]];
            
            self.humidityLabel.text = [[json objectForKey:@"current_observation"] objectForKey:@"relative_humidity"];
            
            self.windLabel.text = [self formatWindWithDir:
                                   [[json objectForKey:@"current_observation"] objectForKey:@"wind_dir"]
                                                 andSpeed:[[json objectForKey:@"current_observation"] objectForKey:@"wind_kph"]];
            
            float pressureThor =[[[json objectForKey:@"current_observation"] objectForKey:@"pressure_mb"] floatValue] * 0.75006;
            self.pressureLabel.text = [NSString stringWithFormat:@"%1.2f мм рт. ст.", pressureThor];
            
            
            //map
            CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longtitude);
            
            MapLocation *annotation = [[MapLocation alloc] initWithCoordinates:location title:locationLabel.text subTitle: [NSString stringWithFormat:@"Ш:%1.2f, Д:%1.2f", latitude, longtitude]];
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self.mapView addAnnotation:annotation];
            self.mapView.centerCoordinate = annotation.coordinate;
            
            [self.conditionsView setHidden:NO];
            numberOfRequest +=1;
        }
    }
    else
    {
        //NSString *result = [[NSString alloc] initWithData:responseDataForecast encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", result);
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseDataForecast options:kNilOptions error:&error];
        if (!error)
        {
            NSArray *simple = [[[json objectForKey:@"forecast"] objectForKey:@"simpleforecast"] objectForKey:@"forecastday"];
            
            for (NSDictionary *currentDay in simple)
            {
                NSUInteger index = [simple indexOfObject:currentDay];
                
                NSString *day = [NSString stringWithFormat:@"%@", [[currentDay objectForKey:@"date"] objectForKey:@"weekday_short"]];
                NSString *date = [NSString stringWithFormat:@"%@/%@",
                                  [[currentDay objectForKey:@"date"] objectForKey:@"day"],
                                  [[currentDay objectForKey:@"date"] objectForKey:@"month"]];
                [[self.forecastDay objectAtIndex:index] setText:[NSString stringWithFormat:@"%@\n%@",date,day]];
                
                NSURL *imgURL =[ NSURL URLWithString:[NSString stringWithFormat:@"%@", [currentDay objectForKey:@"icon_url"]]];
                NSData *data = [[NSData alloc]initWithContentsOfURL:imgURL];
                UIImage *image = [[UIImage alloc]initWithData:data];
                [[self.forecastWeatherImage objectAtIndex:index] setImage:image];
                
                NSString *temp = [NSString stringWithFormat:@"%@..%@",
                                  [self formatTemperature:[[currentDay objectForKey:@"low"] objectForKey:@"celsius"]],
                                  [self formatTemperature:[[currentDay objectForKey:@"high"] objectForKey:@"celsius"]]];
                [[self.forecastTemp objectAtIndex:index] setText:temp];
                
                NSString *hum = [NSString stringWithFormat:@"%@",
                                 [self formatHumidity:[currentDay objectForKey:@"avehumidity"]]];
                [[self.forecastHumid objectAtIndex:index] setText:hum];
                
                NSString *wind = [self formatWindWithDir:[[currentDay objectForKey:@"avewind"] objectForKey:@"dir"] andSpeed:[[currentDay objectForKey:@"avewind"] objectForKey:@"kph"]];
                [[self.forecastWind objectAtIndex:index] setText:wind];
            }
            
            [self.forecastView setHidden:NO];
            numberOfRequest +=1;
        }
    }
    
    if (numberOfRequest == 2)
        [self.indicator stopAnimating];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка!" message:@"Проверьте интернет соединение."delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self.indicator stopAnimating];
    
    if (connection == connectionConditions)
    {
        NSLog(@"Conditions error: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"Forecast error: %@", [error localizedDescription]);
    }
}

- (void)sendRequestForecastWithLatitude:(double)newLatitude withLongitude:(double)newLongitude
{
    NSString *weatherString = @"http://api.wunderground.com/api/";
    //apikey
    weatherString = [weatherString stringByAppendingString:@"8fb05173dafb9465/"];
    //features
    weatherString = [weatherString stringByAppendingString:@"forecast10day/"];
    //settings
    weatherString = [weatherString stringByAppendingString:@"lang:RU/q/"];
    //latitude & longitude
    NSString *quary = [NSString stringWithFormat:@"%f,%f", newLatitude, newLongitude];
    weatherString = [weatherString stringByAppendingString:quary];
    //format
    weatherString = [weatherString stringByAppendingString:@".json"];
    
    NSURL *weatherURL = [NSURL URLWithString:weatherString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:weatherURL];
    connectionForecast = [[NSURLConnection alloc] initWithRequest:request delegate:self];}

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
    
    NSURLRequest *request = [NSURLRequest requestWithURL:weatherURL];
    connectionConditions = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

@end
