//
//  Parking.m
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 05/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import "Parking.h"


@implementation Parking

@synthesize parkingName;
@synthesize parkingDescription;
@synthesize parkingLongitude;
@synthesize parkingLatitude;
@synthesize parkingAdress;
@synthesize parkingId;

-(void) dealloc{
	[parkingName release];
	[parkingDescription release];
	[super dealloc];
}

@end
