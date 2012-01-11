//
//  FirstViewController.h
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 04/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKReverseGeocoder.h>
#import <iAd/ADBannerView.h>

@class ParkingBordeauxAppDelegate;
@class SimpleAnnotation;

@interface MapController : UIViewController<MKReverseGeocoderDelegate, ADBannerViewDelegate> {
	MKMapView *mapViewController;
	MKReverseGeocoder *reverse;
	
	NSString *currentAdress;
	NSString *titreTmp;
	NSString *descriptionTmp;
	NSNumber *tagTmp;
	NSNumber *oldTag;
	
	BOOL isChecked;
	
	ParkingBordeauxAppDelegate *delegate;
	
	id currentLocation;
	
	SimpleAnnotation *annotationTmp;
	
	UIView *contentView;
	id adBannerView;
	BOOL adBannerViewIsVisible;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapViewController;
@property (nonatomic, retain) NSMutableArray *parkings;
@property (nonatomic, retain) ParkingBordeauxAppDelegate *delegate;
@property (nonatomic, retain) MKReverseGeocoder *reverse;
@property (nonatomic, retain) NSString *currentAdress;
@property (nonatomic, retain) NSString *titreTmp;
@property (nonatomic, retain) NSString *descriptionTmp;
@property (nonatomic, retain) NSNumber *tagTmp;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;
@property (nonatomic, retain) SimpleAnnotation *annotationTmp;
@property (nonatomic) BOOL isChecked;
@property (nonatomic, retain) NSNumber *oldTag;

-(void)afficherDetails:(id )sender;

-(void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;

-(void)readFromUserPref;

@end
