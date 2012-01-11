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
#pragma mark sqlite Method

-(NSString *)copyDatabaseToDocuments{
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsPath = [paths objectAtIndex:0];
	NSString *filePath = [documentsPath stringByAppendingPathComponent:@"parkings3.sqlite"];
	
	if (![fileManager fileExistsAtPath:filePath]) {
		NSString *bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"parkings3.sqlite"];
		[fileManager copyItemAtPath:bundlePath toPath:filePath error:nil];
	}
	return filePath;
}

-(void)readParkingsFromDatabaseWithPath:(NSString *)filepath{
	sqlite3 *database;
	
	if (sqlite3_open([filepath UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = "select * from ParkingNote";
		sqlite3_stmt *compiledStatement;
		if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
				
				parkingString = [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 0)];
				etageString = [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 1)];
				placeString = [NSString stringWithUTF8String:(char *) sqlite3_column_text(compiledStatement, 2)];
							
			}
		}
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
}

-(void)insertIntoDatabase:(NSString *)filepath parking:(NSString *)parking etage:(NSString *)etage place:(NSString *)place{
	sqlite3 *database;
	
	if (sqlite3_open([filepath UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = "delete from ParkingNote";
		sqlite3_stmt *compiledStatement;
		if (sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			if (sqlite3_step(compiledStatement) == SQLITE_DONE) {
				sqlite3_finalize(compiledStatement);
			}
		}
		const char *sqlStatement2 = "insert into ParkingNote('parking', 'etage', 'place') values(?, ?, ?)";
		sqlite3_stmt *compiledStatement2;
		
		if (sqlite3_prepare_v2(database, sqlStatement2, -1, &compiledStatement2, NULL) == SQLITE_OK) {

			sqlite3_bind_text(compiledStatement2, 1, [parking UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(compiledStatement2, 2, [etage UTF8String], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(compiledStatement2, 3, [place UTF8String], -1, SQLITE_TRANSIENT);
			
		}
		
		if (sqlite3_step(compiledStatement2) == SQLITE_DONE) {
			sqlite3_finalize(compiledStatement);
		}
	}
	sqlite3_close(database);
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

	parkingString = parkingField.text;
	placeString = placeField.text;
	etageString = etageField.text;
	
	NSString *filepath = [self copyDatabaseToDocuments];
	
	if ([parkingString length] == 0) {
		parkingString = @"";
	}
	if ([placeString length] == 0) {
		placeString = @"";
	}
	if ([etageString length] == 0) {
		etageString = @"";
	}
	
	[self insertIntoUserPref:etageString place:placeString];
	
	[self insertIntoDatabase:filepath parking:parkingString etage:etageString place:placeString];
	
}

-(void) viewWillAppear:(BOOL)animated{
	[super viewWillAppear:YES];
	NSString *filepath = [self copyDatabaseToDocuments];
	[self readParkingsFromDatabaseWithPath:filepath];
	
	placeField.text = placeString;
	parkingField.text = parkingString;
	etageField.text = etageString;
	
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
