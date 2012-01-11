//
//  FirstViewController.m
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 04/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import "MapController.h"
#import "ParkingBordeauxAppDelegate.h"
#import "Parking.h"
#import "SimpleAnnotation.h";
#import "DetailView.h"
#include "sqlite3.h";


@implementation MapController


@synthesize mapViewController;
@synthesize parkings;
@synthesize delegate;
@synthesize reverse;
@synthesize currentAdress;
@synthesize titreTmp;
@synthesize descriptionTmp;
@synthesize tagTmp;
@synthesize adBannerView;
@synthesize adBannerViewIsVisible;
@synthesize contentView;
@synthesize annotationTmp;
@synthesize isChecked;
@synthesize oldTag;

#pragma mark -
#pragma mark userPref Method

-(void)readFromUserPref{
	NSUserDefaults *pref;
	pref = [NSUserDefaults standardUserDefaults];
	tagTmp = [pref objectForKey:@"parkingTag"];
	isChecked = [pref boolForKey:@"isChecked"];
	oldTag = [pref objectForKey:@"oldTag"];
}

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
#pragma mark annotation method

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	
	MKPinAnnotationView *annView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
	
	// Empeche le current Location d'être modifié
	if (annotation == mapView.userLocation) {
		
		currentLocation = annotation;
		
		reverse = [[MKReverseGeocoder alloc] initWithCoordinate:[annotation coordinate]];
		
		reverse.delegate = self;
		
		[reverse start];
		
		return nil;
	}
	
	NSNumber *tag = ((SimpleAnnotation *)annotation).tag; // Le tag, passé au bouton, va permettre d'afficher les détails en fonction de l'annotation
	UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	[rightButton addTarget:self action:@selector(afficherDetails:) forControlEvents:UIControlEventTouchUpInside];
	
	rightButton.tag = [tag intValue];
	
	if ([tag intValue] == [tagTmp intValue] && isChecked == YES) {
		
		[annView setPinColor:MKPinAnnotationColorGreen];
		[annView setCanShowCallout:YES];
		
		annView.rightCalloutAccessoryView = rightButton;
		
		[annView setAnimatesDrop:NO];
		
		return annView;
	}
	
	if ([tag intValue] == [oldTag intValue] || ([tag intValue] == [tagTmp intValue] && isChecked == NO) ) {
		[annView setPinColor:MKPinAnnotationColorPurple];
		
		// Animtation de l'annotation (tombant du ciel)
		[annView setAnimatesDrop:NO];
		
		// Affichage d'information de l'annotation (en cas de clic dessus)
		[annView setCanShowCallout:YES];
		
		annView.rightCalloutAccessoryView = rightButton;
		
		return annView;
	}
	
	// Couleur de l'annotation
	[annView setPinColor:MKPinAnnotationColorPurple];
	
	// Animtation de l'annotation (tombant du ciel)
	[annView setAnimatesDrop:YES];
	 
	// Affichage d'information de l'annotation (en cas de clic dessus)
	[annView setCanShowCallout:YES];
		
	annView.rightCalloutAccessoryView = rightButton;
						
	return annView;
}

-(void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
	[currentLocation setTitle:@"Position Actuelle"];
}

-(void) reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
	
	if ([[placemark subThoroughfare] length] == 0 || [[placemark thoroughfare] length] == 0 || [[placemark postalCode] length] == 0 || [[placemark locality] length] == 0) {
		currentAdress = @"Position Actuelle";
		NSLog(@"un des string est nul");
	}else {
		currentAdress = [NSString stringWithFormat:@"%@ %@, %@ %@", [placemark subThoroughfare], [placemark thoroughfare], [placemark postalCode], [placemark locality]];
	}
		
	[currentLocation setTitle:currentAdress];
	
}

-(void)afficherDetails:(id )sender{

	//DetailView *detailView = [[[DetailView alloc] initWithTitle:titreTmp andDescription:descriptionTmp] autorelease];
	DetailView *detailView = [[DetailView alloc] initWithTag:((UIButton *)sender).tag];
	
	UINavigationController *navigationControllerDetail = [[UINavigationController alloc] initWithRootViewController:detailView];
	
	UIBarButtonItem *doneButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:detailView action:@selector(pushDone)] autorelease];
	
	navigationControllerDetail.navigationBar.topItem.leftBarButtonItem = doneButton;
	
	[self presentModalViewController:navigationControllerDetail animated:YES];

	[navigationControllerDetail release];
}

#pragma mark -
#pragma mark application lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[self createBannerView];	
	
	[self readFromUserPref];
	
	[super viewDidLoad];
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];

	[self readFromUserPref];	
	
	[self fixupAdView:[UIDevice currentDevice].orientation];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	[self fixupAdView:toInterfaceOrientation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	self.contentView = nil;
	self.adBannerView = nil;
	self.mapViewController = nil;
	[mapViewController release];	
	[currentAdress release];
	[parkings release];
	[tagTmp release];
	[delegate release];
	[reverse release];
	[titreTmp release];
	[contentView release];
	[adBannerView release];
	[descriptionTmp release];
	[annotationTmp release];
	[oldTag release];
    [super dealloc];
}

@end
