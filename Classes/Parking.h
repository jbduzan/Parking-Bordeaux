//
//  Parking.h
//  ParkingBordeaux
//
//  Created by Jean-Baptiste DUZAN on 05/05/11.
//  Copyright 2011 Jbduzan. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Parking : NSObject {
	NSString *parkingName;
	NSString *parkingDescription;
	NSString *parkingAdress;
	NSNumber *parkingId;
	double parkingLongitude;
	double parkingLatitude;
}

@property (nonatomic, retain) NSString *parkingName;
@property (nonatomic, retain) NSString *parkingDescription;
@property (nonatomic) double parkingLongitude;
@property (nonatomic) double parkingLatitude;
@property (nonatomic, retain) NSString *parkingAdress;
@property (nonatomic, retain) NSNumber *parkingId;

@end
