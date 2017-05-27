//
//  ViewController.m
//  GMSMapViewScale_Example
//
//  Created by Christian Greth on 26.05.17.
//  Copyright © 2017 Christian Greth. All rights reserved.
//

#import <GoogleMaps/GMSCameraPosition.h>
#import <GoogleMaps/GMSMarker.h>

#import "CHGMapView.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)loadView {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    CHGMapView *mapView = [CHGMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    self.view = mapView;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
