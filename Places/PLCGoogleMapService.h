//
//  PLCGoogleMapService.h
//  Places
//
//  Created by azat on 28/11/15.
//  Copyright © 2015 azat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^PLCSuccessBlock)(id);
typedef void(^PLCFailureBlock)(NSError *);

@interface PLCGoogleMapService : NSObject

- (void)getPlacesNearCoordinate:(CLLocationCoordinate2D)location
                        success:(PLCSuccessBlock)successBlock
                        failure:(PLCFailureBlock)failure;


- (void)getImage:(NSString*)photoRef ;

//Searching by Text methods
- (void)getPlacesByText:(NSString*)text
                success:(PLCSuccessBlock)successBlock
                failure:(PLCFailureBlock)failure;

- (void)getplacesImages:(NSString*)imageURL
                success:(PLCSuccessBlock)successBlock
                failure:(PLCFailureBlock)failure;

@end
