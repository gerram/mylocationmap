//
//  GERViewController.h
//  MyLocationMap
//
//  Created by George Malushkin on 7/6/13.
//  Copyright (c) 2013 George Malushkin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GERViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *distanceLabel;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *northPole;

- (IBAction)createStartingPoint:(id)sender;

- (float)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc;

@end
