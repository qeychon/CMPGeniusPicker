//
//  CMPMathUtil.m
//  CMPGeniusPicker
//
//  Created by Michael Radle on 15.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import "CMPMathUtil.h"
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation CMPMathUtil

+ (CGFloat)radiusRelationOfMainRadius: (CGFloat)mainRadius
                            itemCount: (NSInteger)itemCount
{
    return sin(M_PI / itemCount) / (1 + sin(M_PI / itemCount)) * mainRadius * 2;
}

+ (CGPoint)xyPositionOfAngle: (CGFloat)angle
                      radius: (CGFloat)radius
{
    CGFloat radiant = DEGREES_TO_RADIANS(angle);
    return CGPointMake(radius + radius * cos(radiant) ,
                       radius + radius * sin(radiant));
}

@end
