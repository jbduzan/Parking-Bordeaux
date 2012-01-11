//
//  NoteController.h
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 04/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/ADBannerView.h>

@class ParkingBordeauxAppDelegate;

@interface NoteController : UIViewController<UITextFieldDelegate, ADBannerViewDelegate> {
	IBOutlet UITextField *parkingField;
	IBOutlet UITextField *etageField;
	IBOutlet UITextField *placeField;

	NSString *parkingString;
	NSString *etageString;
	NSString *placeString;
	
	id adBannerView;
	BOOL adBannerViewIsVisible;
}

@property (nonatomic, retain) UITextField *parkingField;
@property (nonatomic, retain) UITextField *etageField;
@property (nonatomic, retain) UITextField *placeField;
@property (nonatomic, retain) NSString *parkingString;
@property (nonatomic, retain) NSString *etageString;
@property (nonatomic, retain) NSString *placeString;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) id adBannerView;
@property (nonatomic) BOOL adBannerViewIsVisible;

-(void) fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation;

-(void)insertIntoUserPref:(NSString *)etage place:(NSString *)place;

@end
