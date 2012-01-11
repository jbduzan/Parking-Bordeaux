//
//  DetailView.m
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 08/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import "DetailView.h"
#import "SimpleAnnotation.h"
#import "ParkingBordeauxAppDelegate.h"
#import "Parking.h"
#include "sqlite3.h"
#import "MapController.h"
#import "JSONKit.h"

@implementation DetailView

@synthesize titleLabel;
@synthesize descriptionTextView;
@synthesize titreTmp;
@synthesize descriptionTmp;
@synthesize tagAnnotation;
@synthesize latitude;
@synthesize longitude;
@synthesize mapController;
@synthesize parkings;
@synthesize responseData;
@synthesize theUrl;
@synthesize parkButton;
@synthesize parkChecked;
@synthesize locationManager;
@synthesize parkingId;
@synthesize distanceLabel;
@synthesize oldTag;

-(IBAction)pushDone{
	[self dismissModalViewControllerAnimated:YES];
	ParkingBordeauxAppDelegate *delegate = (ParkingBordeauxAppDelegate *)[[UIApplication sharedApplication] delegate];
	[delegate refreshParkedAnnotation];
}

-(IBAction)pushPark{
	
	if (parkChecked == NO) {
		[parkButton setTitle:@"Je ne suis plus garé ici" forState:UIControlStateNormal];
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"red-button" ofType:@"png"];
		UIImage *redButton = [[UIImage alloc] initWithContentsOfFile:filePath];
		
		[parkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[parkButton setBackgroundImage:redButton forState:UIControlStateNormal];
		
		parkChecked = YES;
		
		[self insertIntoUserPref];
				
		[redButton release];
		
	}else {
		[parkButton setTitle:@"Je suis garé ici" forState:UIControlStateNormal];
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"green-button" ofType:@"png"];
		UIImage *greenButton = [[UIImage alloc] initWithContentsOfFile:filePath];

		[parkButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[parkButton setBackgroundImage:greenButton forState:UIControlStateNormal];
		
		parkChecked = NO;
		
		[self insertIntoUserPref];
		
		[greenButton release];
				
	}		
}

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
	UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"error" message:@"Une erreur c'est produite lors du chargement des informations. Merci de réessayer plus tard" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[errorView show];
	[errorView autorelease];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection{
	
	NSError *error;
	JSONDecoder *decoder = [[[JSONDecoder alloc] init] autorelease];
	
	NSDictionary *json = [decoder objectWithData:responseData error:&error];
	
	if (json == nil) {
		UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"error" message:@"Une erreur c'est produite. Merci de réessayer plus tard" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
		[errorView show];
		[errorView autorelease];
	}else {
		parkings = [json objectForKey:@"Parkings"];
		
		for (NSDictionary *trend in parkings) {
			if ([[trend objectForKey:@"id"] isEqualToString:[tagAnnotation stringValue]]) {

				NSString *parkingName = [trend objectForKey:@"parkingName"];
				NSString *parkingDescription = [trend objectForKey:@"parkingDescription"];
				
				titreTmp = parkingName;
				parkingDescription = [parkingDescription stringByReplacingOccurrencesOfString:@"U+2023" withString:@"\n"];
				parkingDescription = [parkingDescription stringByReplacingOccurrencesOfString:@"&eacute;" withString:@"é"];
				parkingDescription = [parkingDescription stringByReplacingOccurrencesOfString:@"&egrave;" withString:@"è"];
				parkingDescription = [parkingDescription stringByReplacingOccurrencesOfString:@"&agrave;" withString:@"à"];
				descriptionTmp = parkingDescription;
			
				latitude = [trend objectForKey:@"latitude"];
				longitude = [trend objectForKey:@"longitude"];
				
				CLLocation *parkingCoord = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
				
				ParkingBordeauxAppDelegate *delegate = (ParkingBordeauxAppDelegate *)[[UIApplication sharedApplication] delegate];
				
				CLLocation *userCoord = [[CLLocation alloc] initWithLatitude:delegate.userLocation.coordinate.latitude longitude:delegate.userLocation.coordinate.longitude];
				
				float distanceTemp = [userCoord distanceFromLocation:parkingCoord];
				
				NSString *distance = [[NSString alloc] initWithFormat:@"%.f mètres", distanceTemp];
								
				distanceLabel.text = distance;
				descriptionTextView.text = descriptionTmp;
				titleLabel.text = titreTmp;
				
				self.title = titreTmp;
				
				[distance release];
				[userCoord release];
				[parkingCoord release];
				
				break;
			}
		}
		
		//[decoder release];
	}	
	
}

#pragma mark -
#pragma mark userPref Method

-(void)insertIntoUserPref{
	NSUserDefaults *pref;
	pref = [NSUserDefaults standardUserDefaults];
	[pref setInteger:[tagAnnotation intValue] forKey:@"parkingTag"];
	[pref setBool:parkChecked forKey:@"isChecked"];
	[pref setInteger:[oldTag intValue] forKey:@"oldTag"];
}

#pragma mark -
#pragma mark initialisation method

-(id)initWithTitle:(NSString *)title andDescription:(NSString *)description{
	if (self = [super init]) {
		titreTmp = [NSString stringWithString:title];
		descriptionTmp = [NSString stringWithString:description];
	}

	return self;
}

-(id) initWithTag:(int )tag{
	if (self = [super init]) {
		tagAnnotation = [[NSNumber alloc] initWithInt:tag];
		titreTmp = [[NSString alloc] init];
		descriptionTmp = [[NSString alloc] init];
	}
	return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	NSUserDefaults *pref;
	pref = [NSUserDefaults standardUserDefaults];
	
	parkChecked = [pref boolForKey:@"isChecked"];
	NSNumber *tagTmp = [NSNumber numberWithInt:[pref integerForKey:@"parkingTag"] ];
	
	oldTag = [[NSNumber alloc] initWithInt:[tagTmp intValue]];
		
	if (([tagTmp intValue] == [tagAnnotation intValue] && parkChecked == YES) || ([tagAnnotation intValue] == [oldTag intValue] && parkChecked == YES)) {
		[parkButton setTitle:@"Je ne suis plus garé ici" forState:UIControlStateNormal];
		
		NSString *filePath = [[NSBundle mainBundle] pathForResource:@"red-button" ofType:@"png"];
		UIImage *redButton = [[UIImage alloc] initWithContentsOfFile:filePath];
			
		[parkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[parkButton setBackgroundImage:redButton forState:UIControlStateNormal];
			
		[redButton release];
			
	}else {
		parkChecked = NO;
	}

	
	[self queryServiceWithParent:self];
	
	descriptionTextView.text = descriptionTmp;
	titleLabel.text = titreTmp;

	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[parkingId release];
	[locationManager release];
	[parkButton release];
	[theUrl release];
	[responseData release];
	[parkings release];
	[mapController release];
	[longitude release];
	[latitude release];
	[titleLabel release];
	[descriptionTextView release];
	[titreTmp release];
	[tagAnnotation release];
	[descriptionTmp release];
	[distanceLabel release];
	[oldTag release];
    [super dealloc];
}


@end
