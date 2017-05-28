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

- (void)loadView
{
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    CHGMapView *mapView = [CHGMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    self.view = mapView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"GMSMapView with Scale";
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *normal = [[UIBarButtonItem alloc] initWithTitle:@"Normal" style:UIBarButtonItemStylePlain target:self action:@selector(normal)];
    UIBarButtonItem *satelite = [[UIBarButtonItem alloc] initWithTitle:@"Satellite" style:UIBarButtonItemStylePlain target:self action:@selector(satellite)];
    
    self.toolbarItems = @[flex, normal, flex, satelite, flex];
    
}

- (void)normal
{
    ((GMSMapView *)self.view).mapType = kGMSTypeNormal;
}

- (void)satellite
{
    ((GMSMapView *)self.view).mapType = kGMSTypeSatellite;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
