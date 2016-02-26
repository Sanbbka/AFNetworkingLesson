//
//  PLCPlace.h
//  Places
//
//  Created by azat on 28/11/15.
//  Copyright © 2015 azat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@interface PLCPlace : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) UIImage *image;

@end
