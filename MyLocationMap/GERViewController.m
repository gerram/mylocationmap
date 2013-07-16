//
//  GERViewController.m
//  MyLocationMap
//
//  Created by George Malushkin on 7/6/13.
//  Copyright (c) 2013 George Malushkin. All rights reserved.
//

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

#import "GERViewController.h"

@interface GERViewController ()

@end

@implementation GERViewController
{
    CLLocationManager *locationManager;
    CLLocation *startingPoint;
    float angleVal;
    
    MKPolyline *pathOverlay; // line for path to home
}

@synthesize mapView;
@synthesize distanceLabel;
@synthesize northPole;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Map
    self.mapView.delegate = self;
    
    // Location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
//    if([CLLocationManager locationServicesEnabled] &&  [CLLocationManager headingAvailable])
//	{
//		[locationManager startUpdatingLocation];
//		[locationManager startUpdatingHeading];
//	} else {
//		NSLog(@"Can't report heading");
//	}
    //[locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 550, 550);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    
    // if I want to have an annotation
//    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
//    point.coordinate = userLocation.coordinate;
//    point.title = @"Where am I?";
//    point.subtitle = @"I'm here!!!";
//    
//    [self.mapView addAnnotation:point];
    
    // if startinPoint exists
    if (startingPoint != nil) {
        CLLocationCoordinate2D tmp;
        tmp.latitude = userLocation.coordinate.latitude;
        tmp.longitude = userLocation.coordinate.longitude;
        CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:tmp.latitude longitude:tmp.longitude];
        
        CLLocationDistance distance = [newLocation distanceFromLocation:startingPoint];
        distanceLabel.text = [[NSString alloc] initWithFormat:@"%0.f meters", distance];
        
        // remove old line
        if (pathOverlay != nil) {
            [self.mapView removeOverlays: [NSArray arrayWithObjects:pathOverlay, nil]];
            pathOverlay = nil;
        }
        
        // paint line overlay
        CLLocationCoordinate2D pathCoords[2] =
        {
            CLLocationCoordinate2DMake(startingPoint.coordinate.latitude, startingPoint.coordinate.longitude),
            CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
        };
        
        pathOverlay = [MKPolyline polylineWithCoordinates:pathCoords count:2];
        [self.mapView addOverlays: [NSArray arrayWithObjects: pathOverlay, nil]];
        
        CLLocationCoordinate2D fromLoc = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
        CLLocationCoordinate2D toLoc = CLLocationCoordinate2DMake(startingPoint.coordinate.latitude, startingPoint.coordinate.longitude);
        angleVal = [self getHeadingForDirectionFromCoordinate:fromLoc toCoordinate:toLoc];
    }
    
}


- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        return degree;
    } else {
        return 360+degree;
    }
}



- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView *view = [[MKPolylineView alloc] initWithOverlay:overlay];
        //Display settings
        view.lineWidth = 1;
        view.strokeColor = [UIColor blueColor];
        return view;
    }
    
    return nil;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //UIDevice *device = [UIDevice currentDevice];
    
    if (newHeading.headingAccuracy > 0) {
        
        float magneticHeading = newHeading.magneticHeading;
        
        // +- 25 degrees for correct path
        float valueRange = 50;
        float minAnglePath;
        float maxAnglePath;
        
        minAnglePath = angleVal - valueRange/2;
        if (minAnglePath < 0) {
            minAnglePath += 360;
        }
        
        maxAnglePath = angleVal + valueRange/2;
        // let have degrees more 360 for correct analazing range of home path
        
        
        if (magneticHeading >= minAnglePath && magneticHeading <= maxAnglePath) {
            northPole.text = @"The home over there!!!";
        } else {
            northPole.text = [[NSString alloc] initWithFormat:@"pole: %.3f, start: %.3f", magneticHeading, angleVal];
        }
    }
}


- (IBAction)createStartingPoint:(id)sender {
    
    CLLocationCoordinate2D tmp;
    tmp.latitude = self.mapView.userLocation.coordinate.latitude;
    tmp.longitude = self.mapView.userLocation.coordinate.longitude;
    
    if (startingPoint) {
        startingPoint = nil;
    }
    
    startingPoint = [[CLLocation alloc] initWithLatitude:tmp.latitude longitude:tmp.longitude];
    
}

@end
