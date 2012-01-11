//
//  SimpleAnnotation.m
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 05/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import "SimpleAnnotation.h"
#import "Parking.h"


@implementation SimpleAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize description;
@synthesize tag;

+(id)annotationWithCoordinate:(CLLocationCoordinate2D)coord{
	return [[[[self class] alloc] initWithCoordinate:coord] autorelease];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord{
	if (self = [super init]) {
		self.coordinate = coord;
	}
	return self;
}

-(void) dealloc{
	[title release];
	[subtitle release];
	[description release];
	[tag release];
	[super dealloc];
}

@end
