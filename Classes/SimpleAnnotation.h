//
//  SimpleAnnotation.h
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 05/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class Parking;

@interface SimpleAnnotation : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
	NSString *subtitle;
	NSString *description;
	NSNumber *tag;
}

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSNumber *tag;

+ (id)annotationWithCoordinate:(CLLocationCoordinate2D)coord; 

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;

@end
