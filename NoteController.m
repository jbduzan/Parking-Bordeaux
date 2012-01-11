//
//  NoteController.m
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 04/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import "NoteController.h"
#import "ParkingBordeauxAppDelegate.h"
#include "sqlite3.h"


@implementation NoteController

@synthesize parkingField;
@synthesize etageField;
@synthesize placeField;
@synthesize parkingString;
@synthesize etageString;
@synthesize placeString;
@synthesize contentView;
@synthesize adBannerView;
@synthesize adBannerViewIsVisible;

#pragma mark -
#pragma mark iad Method

-(BOOL) bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
	return YES;
}

-(void) bannerViewDidLoadAd:(ADBannerView *)banner{
	if (!adBannerViewIsVisible) {
		adBannerViewIsVisible = YES;
		[self fixupAdView:[UIDevice currentDevice].orientation];
	}
}

-(void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
	if (adBannerViewIsVisible) {
		adBannerViewIsVisible = NO;
		[self fixupAdView:[UIDevice currentDevice].orientation];
	}
}

-(int) getBannerHeight:(UIDeviceOrientation)orientation{
	if (UIInterfaceOrientationIsLandscape(orientation)) {
		return 32;
	}else {
		return 50;
	}
}

-(int)getBannerHeight{
	return [self getBannerHeight:[UIDevice currentDevice].orientation];
}

-(void)createBannerView{
	Class classAdBannerView = NSClassFromString(@"ADBannerView");
	if (classAdBannerView != nil) {
		self.adBannerView = [[[classAdBannerView alloc]initWithFrame:CGRectZero] autorelease];
		
        [adBannerView setRequiredContentSizeIdentifiers:[NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil]];
        if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            [adBannerView setCurrentContentSizeIdentifier: ADBannerContentSizeIdentifierLandscape];
        } else {
            [adBannerView setCurrentContentSizeIdentifier: ADBannerContentSizeIdentifierPortrait];
        }
        [adBannerView setFrame:CGRectOffset([adBannerView frame], 0,-[self getBannerHeight])];
        [adBannerView setDelegate:self];
		
        [self.view addSubview:adBannerView];
    }
}

-(void)fixupAdView:(UIInterfaceOrientation)toInterfaceOrientation{
	if (adBannerView != nil) {
		if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
			[adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierLandscape];
		}else {
			[adBannerView setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
		}
		
		//[UIView beginAnimations:@"fixupViews" context:nil];
		if (adBannerViewIsVisible) {
			CGRect adBannerViewFrame = [adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = 361;
			[adBannerView setFrame:adBannerViewFrame];
			
			CGRect contentViewFrame = contentView.frame;
			contentViewFrame.origin.y = [self getBannerHeight:toInterfaceOrientation];
			contentViewFrame.size.height = self.view.frame.size.height - [self getBannerHeight:toInterfaceOrientation];
			contentView.frame = contentViewFrame;
		}else {
			CGRect adBannerViewFrame = [adBannerView frame];
			adBannerViewFrame.origin.x = 0;
			adBannerViewFrame.origin.y = -[self getBannerHeight:toInterfaceOrientation];
			[adBannerView setFrame:adBannerViewFrame];
			
			CGRect contentViewFrame = contentView.frame;
			contentViewFrame.origin.x = 0;
			contentViewFrame.size.height = self.view.frame.size.height;
			contentView.frame = contentViewFrame;
		}
		//[UIView commitAnimations];
		
	}
}

#pragma mark -
#pragma mark userPref Method

-(void)insertIntoUserPref:(NSString *)etage place:(NSString *)place{
	NSUserDefaults *pref;
	pref = [NSUserDefaults standardUserDefaults];
	[pref setObject:etage forKey:@"etage"];
	[pref setObject:place forKey:@"place"];
}

#pragma mark -
#pragma mark textfield delegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
	[textField resignFirstResponder];
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Dismiss the keyboard when the view outside the text field is touched.
    [parkingField resignFirstResponder];
	[placeField resignFirstResponder];
	[etageField resignFirstResponder];
	
    [super touchesBegan:touches withEvent:event];
}

#pragma mark -
#pragma mark initialisation method

-(void)viewDidDisappear:(BOOL)animated{
	[super viewDidDisappear:YES];

	placeString = placeField.text;
	etageString = etageField.text;
			
	parkingString = @"";

	if ([placeString length] == 0) {
		placeString = @"";
	}
	if ([etageString length] == 0) {
		etageString = @"";
	}
		
	[self insertIntoUserPref:etageString place:placeString];		
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	//NSString *filepath = [self copyDatabaseToDocuments];
	//[self readParkingsFromDatabaseWithPath:filepath];
	
	NSUserDefaults *pref;
	pref = [NSUserDefaults standardUserDefaults];
	
	placeField.text = [pref stringForKey:@"place"];
	etageField.text = [pref stringForKey:@"etage"];
	
	[self fixupAdView:[UIDevice currentDevice].orientation];
}

-(void) viewDidLoad{
	
	placeField.clearButtonMode = UITextFieldViewModeWhileEditing;
	parkingField.clearButtonMode = UITextFieldViewModeWhileEditing;
	etageField.clearButtonMode = UITextFieldViewModeWhileEditing;
	
	[self createBannerView];
	[super viewDidLoad];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self fixupAdView:toInterfaceOrientation];
}

-(void) dealloc{
	self.contentView = nil;
	self.adBannerView = nil;
	[parkingField release];
	[etageField release];
	[placeField release];
	[parkingString release];
	[placeString release];
	[etageString release];
	[contentView release];
	[adBannerView release];
	[super dealloc];
}

@end
