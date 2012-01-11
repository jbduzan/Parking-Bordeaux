//
//  DetailView.h
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 08/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class MapController;

@interface DetailView : UIViewController<CLLocationManagerDelegate> {

	UILabel *titleLabel;
	UILabel *distanceLabel;
	UITextView *descriptionTextView;
	
	CLLocationManager *locationManager;
	
	NSString *titreTmp;
	NSString *descriptionTmp;	
	NSNumber *tagAnnotation;
	NSNumber *latitude;
	NSNumber *longitude;	
	NSNumber *parkingId;
	NSNumber *oldTag;
	
	NSMutableData *responseData;
	NSURL *theUrl;
	NSArray *parkings;	
	
	UIButton *parkButton;
	BOOL parkChecked;
	
	MapController *mapController;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, retain) IBOutlet UIButton *parkButton;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) NSString *titreTmp;
@property (nonatomic, retain) NSString *descriptionTmp;
@property (nonatomic, retain) NSNumber *tagAnnotation;
@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) MapController *mapController;
@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURL *theUrl;
@property (nonatomic, retain) NSArray *parkings;
@property (nonatomic) BOOL parkChecked;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) NSNumber *parkingId;
@property (nonatomic, retain) NSNumber *oldTag;

-(IBAction)pushDone;

-(id)initWithTitle:(NSString *)title andDescription:(NSString *)description;

-(id)initWithTag:(int )tag;

-(void)insertIntoUserPref;

-(IBAction)pushPark;


@end
