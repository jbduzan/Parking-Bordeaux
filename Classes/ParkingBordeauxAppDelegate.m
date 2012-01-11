//
//  ParkingBordeauxAppDelegate.m
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 04/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import "ParkingBordeauxAppDelegate.h"
#import "MapController.h"
#import "NoteController.h"
#import "Parking.h"
#import "SimpleAnnotation.h"
#import "Reachability.h"
#import "JSONKit.h"
#include "sqlite3.h"

@implementation ParkingBordeauxAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize mapViewController;
@synthesize locationManager;
@synthesize noteController;
@synthesize parking;
@synthesize parkingLongitude;
@synthesize parkingLatitude;
@synthesize parkingName;
@synthesize parkingDescription;
@synthesize parkingAdress;
@synthesize parkingId;
@synthesize responseData;
@synthesize theUrl;
@synthesize trends;
@synthesize userLocation;
@synthesize networkStatus;
@synthesize pref;

#pragma mark -
#pragma mark jsonMethod

-(void) queryServiceWithParent:(UIViewController *)controller{
	responseData = [[NSMutableData data] retain];
	
	NSString *url = [NSString stringWithFormat:@"http://jbduzan.com/json.php?hascode=496483618e995c72fb07f787fe04eecc"];
	theUrl = [[NSURL URLWithString:url] retain];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:theUrl];
	
	[[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
	[request release];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
	[theUrl autorelease];
	theUrl = [[request URL] retain];
	return request;
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	[responseData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
	[responseData appendData:data];
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"error : %@", error);
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"error" message:@"Une erreur c'est produite. Merci de réessayer plus tard" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[errorView show];
	[errorView autorelease];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
	
	NSError *error;
	JSONDecoder *decoder = [[[JSONDecoder alloc] init] autorelease];
	
	NSDictionary *json = [[[NSDictionary alloc] init] autorelease];
	json = [decoder objectWithData:responseData error:&error];
	
	if ([json count] == 0) { 
		UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"error" message:@"Une erreur c'est produite dans le chargement des données. Merci de réessayer plus tard" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[errorView show];
		[errorView autorelease];
	}else {
		trends = [json objectForKey:@"Parkings"];
		
		for (NSDictionary *trend in trends) {
			parkingId = [trend objectForKey:@"id"];
			parkingName = [trend objectForKey:@"parkingName"];
			parkingDescription = [trend objectForKey:@"parkingDescription"];
			parkingAdress = [trend objectForKey:@"parkingAdress"];
			parkingLatitude = [trend objectForKey:@"latitude"];
			parkingLongitude = [trend objectForKey:@"longitude"];
			
			CLLocationCoordinate2D coord = {[parkingLatitude floatValue], [parkingLongitude floatValue]};
			
			SimpleAnnotation *annotation = [[[SimpleAnnotation alloc] initWithCoordinate:coord] autorelease];
			
			annotation.tag = parkingId;
			annotation.title = parkingName;
			annotation.description = parkingDescription;
			annotation.subtitle = parkingAdress;
			
			[parking addObject:annotation];
		}
                
        // Une fois que on a parsé le string, on initialise le service de localisation si celui-ci a été authorisé
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		if ([CLLocationManager locationServicesEnabled]) {
			self.locationManager.delegate = self;
			self.locationManager.distanceFilter = 500;
			[self.locationManager startUpdatingLocation];
		}
        
	}
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
        
	Reachability *reach = [[[Reachability reachabilityWithHostName: @"jbduzan.com"] retain] autorelease];
	NetworkStatus status = [reach currentReachabilityStatus];
	
	parking = [[NSMutableArray alloc] init];
        	
	if (status == NotReachable) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Vous n'êtes pas connecté à Internet. Veuillez vous connecter et reessayer" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
		[alertView show];
		[alertView autorelease];
		
		// Initialise le service de localisation si celui-ci a été authorisé
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		if ([CLLocationManager locationServicesEnabled]) {
			self.locationManager.delegate = self;
			self.locationManager.distanceFilter = 500;
			[self.locationManager startUpdatingLocation];
		}
		
		// Add the tab bar controller's view to the window and display.
		[self.window addSubview:tabBarController.view];
		[self.window makeKeyAndVisible];
		
		
		return NO;
	}else {       
        // Charge les données des parkings
        [self queryServiceWithParent:mapViewController];
				
		// Add the tab bar controller's view to the window and display.
		[self.window addSubview:tabBarController.view];
		[self.window makeKeyAndVisible];
		
		return YES;
	}
}

-(void)refreshParkedAnnotation{
	pref = [NSUserDefaults standardUserDefaults]; 
	NSNumber *tagTmp = [pref objectForKey:@"parkingTag"];
	NSNumber *oldTag = [pref objectForKey:@"oldTag"];
		
	for (int i = 0; i < [parking count]; i++) {
		SimpleAnnotation *annotation = [parking objectAtIndex:i];
		if ([annotation.tag intValue] == [tagTmp intValue] || [annotation.tag intValue] == [oldTag intValue]) {
			[mapViewController.mapViewController removeAnnotation:annotation];
			[mapViewController.mapViewController addAnnotation:annotation];
		}
	}
}

#pragma mark -
#pragma mark location Method

-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
 
	double miles = 1.0; 
	double scalingFactor = ABS( cos(2 * M_PI * newLocation.coordinate.latitude /360.0) );
	
	MKCoordinateSpan span; 
	span.latitudeDelta = miles/69.0;
	span.longitudeDelta = miles/( scalingFactor*69.0 );

	MKCoordinateRegion region;
	region.span = span;
	region.center = newLocation.coordinate;
	
	[mapViewController.mapViewController setRegion:region animated:YES];
			    
	for (int i = 0; i < [parking count]; i++) {
		SimpleAnnotation *annotation = [[[SimpleAnnotation alloc] init] autorelease];
		annotation = [parking objectAtIndex:i];
		[mapViewController.mapViewController addAnnotation:annotation];
	}
	
	mapViewController.mapViewController.showsUserLocation = YES;
			
	userLocation = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	
}

#pragma mark -
#pragma mark mapkitdelegate method

-(void)mapViewDidFinishLoadingMap:(MKMapView *)mapView{
    
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error{
	
}



#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[networkStatus release];
	[responseData release];
	[theUrl release];
	[trends release];
	[parkingName release];
	[parkingDescription release];
	[parkingLongitude release];
	[parkingLatitude release];
	[parkingId release];
    [tabBarController release];
	[locationManager release];
	[noteController release];
	[parking release];
	[parkingAdress release];
	[mapViewController release];
	[userLocation release];
	[pref release];
    [super dealloc];
}

@end

