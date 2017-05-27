//
//  CHGMapView.m
//  GMSMapViewScale_Example
//
//  Created by Christian Greth on 26.05.17.
//  Copyright © 2017 Christian Greth. All rights reserved.
//

const int KMSCALEVIEWTAG = 998;
const int MISCALEVIEWTAG = 999;
const int SCALEVIEWLABELTAG = 1;
const int SCALEVIEWENDTAG = 2;

const float SCALELINESTRENGTH = 1.f;

const float MAPVIEWTOSCALEVIEWRATIO = .15f;
const float SCALEVIEWBOTTOMPADDING = 30.f;
const float SCALEVIEWRIGHTPADDING = 90.f;

const float KMTOMI = 0.000621371f;

#import "CHGMapView.h"

@implementation CHGMapView {
    NSTimer *updateScaleTimer;
}

+ (instancetype)mapWithFrame:(CGRect)frame camera:(GMSCameraPosition *)camera
{
    CHGMapView *mapView = [super mapWithFrame:frame camera:camera];
    [mapView initScale];
    return mapView;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"camera"];
}

- (void)initScale
{
    // km scale, km label and km end view
    UIView *kmScale = [[UIView alloc] init];
    kmScale.tag = KMSCALEVIEWTAG;
    kmScale.backgroundColor = [UIColor blackColor];
    [self addSubview:kmScale];
    
    UILabel *kmScaleLabel = [[UILabel alloc] init];
    kmScaleLabel.tag = SCALEVIEWLABELTAG;
    kmScaleLabel.textAlignment = NSTextAlignmentRight;
    kmScaleLabel.font = [kmScaleLabel.font fontWithSize:9.f];
    kmScaleLabel.textColor = [UIColor blackColor];
    [kmScale addSubview:kmScaleLabel];
    
    UIView *kmScaleEnd = [[UIView alloc] init];
    kmScaleEnd.tag = SCALEVIEWENDTAG;
    kmScaleEnd.backgroundColor = [UIColor blackColor];
    [kmScale addSubview:kmScaleEnd];
    
    // mi scale, mi label and end view
    UIView *miScale = [[UIView alloc] init];
    miScale.tag = MISCALEVIEWTAG;
    miScale.backgroundColor = [UIColor blackColor];
    [self addSubview:miScale];
    
    UILabel *miScaleLabel = [[UILabel alloc] init];
    miScaleLabel.tag = SCALEVIEWLABELTAG;
    miScaleLabel.textColor = [UIColor blackColor];
    miScaleLabel.textAlignment = NSTextAlignmentRight;
    miScaleLabel.font = [miScaleLabel.font fontWithSize:9.f];
    [miScale addSubview:miScaleLabel];
    
    UIView *miScaleEnd = [[UIView alloc] init];
    miScaleEnd.tag = SCALEVIEWENDTAG;
    miScaleEnd.backgroundColor = [UIColor blackColor];
    [miScale addSubview:miScaleEnd];
    
    [self addObserver:self forKeyPath:@"camera" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath  isEqual: @"camera"]) {
        
        GMSCameraPosition *oldCamera = [change objectForKey:@"old"];
        GMSCameraPosition *newCamera = [change objectForKey:@"new"];
        
        if (oldCamera.zoom != newCamera.zoom) {
            [updateScaleTimer invalidate];
            updateScaleTimer = [NSTimer scheduledTimerWithTimeInterval:0.02f
                                                                target:self
                                                              selector:@selector(updateScale)
                                                              userInfo:nil repeats:NO];
        }
    }
}

- (void)updateScale
{
    // distance
    CLLocationDistance screenM = [self distance];
    
    // distance per pixel
    CGFloat screenPX = CGRectGetWidth(self.bounds);
    CGFloat scalePXmax = screenPX * MAPVIEWTOSCALEVIEWRATIO; //
    
    CGFloat mPerPX = screenM / screenPX;
    CGFloat kmScalePXsize = mPerPX * scalePXmax;
    CGFloat miScalePXsize = kmScalePXsize * KMTOMI;
    
    // place km scale
    NSDictionary *kmScaleText = @{ @10 : @"10 m", @20 : @"20 m", @50 : @"50 m",
                                   @100 : @"100 m", @200 : @"200 m", @500 : @"500 m",
                                   @1000 : @"1 km", @2000 : @"2 km", @5000 : @"5 km",
                                   @10000 : @"10 km", @20000 : @"20 km", @50000 : @"50 km",
                                   @100000 : @"100 km", @200000 : @"200 km", @500000 : @"500 km",
                                   @1000000 : @"1000 km", @2000000 : @"2000 km", @5000000 : @"5000 km",
                                   @10000000 : @"10000 km", @20000000 : @"20000 km", @50000000 : @"50000 km"};
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"floatValue" ascending:YES];
    NSArray *sortedKeys = [[kmScaleText allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSString *kmScaleLabelText = @"";
    
    for (NSNumber *key in sortedKeys) {
        if (key.floatValue / kmScalePXsize > 1.f) {
            kmScalePXsize = scalePXmax * key.floatValue / kmScalePXsize;
            kmScaleLabelText = [kmScaleText objectForKey:key];
            break;
        }
    }
    
    UIView *kmScale = [self viewWithTag:KMSCALEVIEWTAG];
    kmScale.frame = CGRectMake(0, 0, kmScalePXsize, SCALELINESTRENGTH);
    kmScale.center = CGPointMake(CGRectGetWidth(self.bounds) - kmScalePXsize / 2 - SCALEVIEWRIGHTPADDING,
                                 CGRectGetHeight(self.bounds) - SCALEVIEWBOTTOMPADDING);
    
    // place km label -> below scale
    UILabel *kmScaleLabel = [kmScale viewWithTag:SCALEVIEWLABELTAG];
    kmScaleLabel.text = kmScaleLabelText;
    kmScaleLabel.frame = CGRectMake(0, 2, kmScalePXsize, 11);
    
    // place km end line
    UIView *kmScaleEnd = [kmScale viewWithTag:SCALEVIEWENDTAG];
    kmScaleEnd.frame = CGRectMake(0, 0, SCALELINESTRENGTH, 13);
    
    // place mi scale
    NSDictionary *miScaleText = @{ @0.0004734 : @"1 ft", @0.000946 : @"5 ft", @0.001893 : @"10 ft",
                                   @0.0047348 : @"25 ft", @0.009469 : @"50 ft", @0.018939 : @"100 ft",
                                   @0.0473485 : @"250 ft", @0.094697 : @"500 ft", @0.189393 : @"1000 ft",
                                   @0.25 : @"1/4 mi", @0.5 : @"1/2 mi", @0.75 : @"3/4 mi",
                                   @1 : @"1 mi", @2 : @"2 mi", @5 : @"5 mi",
                                   @10 : @"10 mi", @20 : @"20 mi", @50 : @"50 mi",
                                   @100 : @"100 mi", @200 : @"200 mi", @500 : @"500 mi",
                                   @1000 : @"1000 mi", @2000 : @"2000 mi", @5000 : @"5000 mi",
                                   @10000 : @"10000 mi", @20000 : @"20000 mi", @50000 : @"50000 mi",
                                   @100000 : @"100000 mi", @200000 : @"200000 mi", @500000 : @"500000 mi"};
    
    sortedKeys = [[miScaleText allKeys] sortedArrayUsingDescriptors:@[sortDescriptor]];
    NSString *miScaleLabelText = @"";
    
    for (NSNumber *key in sortedKeys) {
        if (key.floatValue / miScalePXsize > 1.f) {
            miScalePXsize = scalePXmax * key.floatValue / miScalePXsize;
            miScaleLabelText = [miScaleText objectForKey:key];
            break;
        }
    }
    
    UIView *miScale = [self viewWithTag:MISCALEVIEWTAG];
    miScale.frame = CGRectMake(0, 0, miScalePXsize, SCALELINESTRENGTH);
    miScale.center = CGPointMake(CGRectGetWidth(self.bounds) - miScalePXsize / 2 - SCALEVIEWRIGHTPADDING,
                                 CGRectGetHeight(self.bounds) - SCALEVIEWBOTTOMPADDING);
    
    // place mi label -> above scale
    UILabel *miScaleLabel = [miScale viewWithTag:SCALEVIEWLABELTAG];
    miScaleLabel.text = miScaleLabelText;
    miScaleLabel.frame = CGRectMake(0, -11, miScalePXsize, 11);
    
    // place mi end line
    UIView *miScaleEnd = [miScale viewWithTag:SCALEVIEWENDTAG];
    miScaleEnd.frame = CGRectMake(0, -13, SCALELINESTRENGTH, 13);
    
    // animate hide
    kmScale.alpha = 1;
    miScale.alpha = 1;
    [UIView animateWithDuration:0.5f
                          delay:2.5f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^(void) {
                         kmScale.alpha = 0;
                         miScale.alpha = 0;
                     }
                     completion:nil];
}

- (CLLocationDistance)distance
{
    GMSProjection *projection = [self projection];
    
    CGPoint leftPoint = CGPointMake(0.f, CGRectGetHeight(self.bounds) - SCALEVIEWBOTTOMPADDING);
    CGPoint rightPoint = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - SCALEVIEWBOTTOMPADDING);
    
    CLLocationCoordinate2D leftCoord = [projection coordinateForPoint:leftPoint];
    CLLocationCoordinate2D rightCoord = [projection coordinateForPoint:rightPoint];
    
    CLLocation *leftLoc = [[CLLocation alloc] initWithLatitude:leftCoord.latitude longitude:leftCoord.longitude];
    CLLocation *rightLoc = [[CLLocation alloc] initWithLatitude:rightCoord.latitude longitude:rightCoord.longitude];
    
    return [leftLoc distanceFromLocation:rightLoc];
}

@end
