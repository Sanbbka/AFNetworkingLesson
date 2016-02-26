//
//  PLCGoogleMapService.m
//  Places
//
//  Created by azat on 28/11/15.
//  Copyright © 2015 azat. All rights reserved.
//

#import "PLCGoogleMapService.h"
#import <AFNetworking.h>
#import "PLCLocationHelper.h"
#import "PLCPlaceMapper.h"
#import <SDWebImageManager.h>

NSString *const PLCGoogleBaseURL = @"https://maps.googleapis.com/maps/api/place/";
NSString *const PLCGoogleAPIKey = @"AIzaSyBhpEhL8vvERVuY9ynrHuElB7kEKdWyiHI";
NSString *const PLCGoogleImageURL = @"https://maps.googleapis.com/maps/api/place/photo?";

@interface PLCGoogleMapService()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

@end


@implementation PLCGoogleMapService

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:PLCGoogleBaseURL];
        _requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    }
    return self;
}


- (void)getPlacesNearCoordinate:(CLLocationCoordinate2D)location
                        success:(PLCSuccessBlock)successBlock
                        failure:(PLCFailureBlock)failure {
    
    NSDictionary *params = @{
                             @"key": PLCGoogleAPIKey,
                             @"location": stringFromCoordinate(location),
                             @"radius": @(1000)
                             };
    
    void(^success)(AFHTTPRequestOperation *, id) =
    ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableArray *placesModels = [NSMutableArray new];
        
        NSArray *results = responseObject[@"results"];
        if (results.count == 0) {
            if (successBlock) {
                successBlock(@[]);
            }
        }
        for (NSDictionary *placeDict in results) {
            [placesModels addObject:[PLCPlaceMapper placeWithDictionary:placeDict]];
        }
        if (successBlock) {
            successBlock([placesModels copy]);
        }
        
    };
    
    void(^fail)(id, NSError *) = ^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    };
    
    [self.requestManager GET:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json"
                  parameters:params
                     success:success
                     failure:fail];
}

- (void)getImage:(NSString*)photoRef {
    if (photoRef != nil) {
        NSDictionary *params = @{
                                 @"key": PLCGoogleAPIKey,
                                 @"maxwidth": @50,
                                 @"photoreference": photoRef
                                 };
        
        
        [self.requestManager GET:PLCGoogleImageURL parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
            
        }];
    }
    
}

- (void)getplacesImages:(NSString*)imageURL
                success:(PLCSuccessBlock)successBlock
                failure:(PLCFailureBlock)failure{
    
    NSString *urlString = [NSString stringWithFormat:@"%@maxheight=100&photoreference=%@&key=%@",PLCGoogleImageURL, imageURL, PLCGoogleAPIKey];
    NSURL *imageWithURL = [NSURL URLWithString:urlString];
    
    [SDWebImageDownloader.sharedDownloader downloadImageWithURL:imageWithURL
                                                        options:0
     
                                                       progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         //         // progression tracking code
         //         NSLog(@"ExpectedSize: %ld",(long)expectedSize);
         //         NSLog(@"ReceivedSize: %ld",(long)receivedSize);
     }
                                                      completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
     {
         if (image && finished)
         {
             // do something with image
             dispatch_async(dispatch_get_main_queue(), ^{
                 successBlock(image);
             });
             
         }
         else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 failure(error);
             });
         }
     }];
}

#pragma mark SearchByText methods

- (void)getPlacesByText:(NSString*)text
                success:(PLCSuccessBlock)successBlock
                failure:(PLCFailureBlock)failure {
    NSDictionary *params = @{
                             @"key": PLCGoogleAPIKey,
                             @"query": text,
                             @"radius": @(1000)
                             };
    
    void(^success)(AFHTTPRequestOperation *, id) =
    ^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSMutableArray *placesModels = [NSMutableArray new];
        
        NSString *status = responseObject[@"status"];
        
        if ([status isEqualToString:@"OK"]) {
            NSArray *results = responseObject[@"results"];
            if (results.count == 0) {
                if (successBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        successBlock(@[]);
                    });
                }
            }
            for (NSDictionary *placeDict in results) {
                [placesModels addObject:[PLCPlaceMapper placeWithDictionary:placeDict]];
            }
            if (successBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    successBlock([placesModels copy]);
                });
            }
            
        } else {
            if (failure) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *errorMessage = responseObject[@"error_message"];
                    if (errorMessage != nil) {
                        NSDictionary *dict = @{@"localizedDescription": errorMessage};
                        NSError *error = [NSError errorWithDomain:@"PLCErrorDomain" code:-1 userInfo:dict];
                        failure(error);
                    }
                });
            }
        }
    };
    
    void(^fail)(id, NSError *) = ^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        failure(error);
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.requestManager GET:@"https://maps.googleapis.com/maps/api/place/textsearch/json"
                      parameters:params
                         success:success
                         failure:fail];
    });
    
}


@end
