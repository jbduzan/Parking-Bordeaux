//
//  ParkingBordeauxAppDelegate.h
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 04/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class MapController;
@class NoteController;
@class Parking;
@class SimpleAnnotation;

@interface ParkingBordeauxAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, MKMapViewDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	MapController *mapViewController;
	NoteController *noteController;
	CLLocationManager *locationManager;
	
	NSString *parkingName;
	NSString *parkingDescription;
	NSString *parkingAdress;
	NSNumber *parkingLongitude;
	NSNumber *parkingLatitude;
	NSNumber *parkingId;
	NSString *networkStatus;
	NSUserDefaults *pref;
	
	CLLocation *userLocation;
	
	NSMutableData *responseData;
	NSURL *theUrl;
	NSArray *trends;
	
	NSMutableArray *parking;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet CLLocationManager *locationManager;
@property (nonatomic, retain) IBOutlet MapController *mapViewController;
@property (nonatomic, retain) IBOutlet NoteController *noteController;
@property (nonatomic, retain) NSMutableArray *parking;
@property (nonatomic, retain) NSString *parkingName;
@property (nonatomic, retain) NSString *parkingDescription;
@property (nonatomic, retain) NSNumber *parkingLongitude;
@property (nonatomic, retain) NSNumber *parkingLatitude;
@property (nonatomic, retain) NSString *parkingAdress;
@property (nonatomic, retain) NSNumber *parkingId;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURL *theUrl;
@property (nonatomic, retain) NSArray *trends;
@property (nonatomic, retain) CLLocation *userLocation;
@property (nonatomic, retain) NSString *networkStatus;
@property (nonatomic, retain) NSUserDefaults *pref;

-(void)refreshParkedAnnotation;

@end
