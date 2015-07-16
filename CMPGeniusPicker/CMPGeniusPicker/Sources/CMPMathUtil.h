//
//  CMPMathUtil.h
//  CMPGeniusPicker
//
//  Created by Michael Radle on 15.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CMPMathUtil : NSObject

+ (CGFloat)radiusRelationOfMainRadius: (CGFloat)mainRadius
                            itemCount: (NSInteger)itemCount;

+ (CGPoint)xyPositionOfAngle: (CGFloat)angle radius: (CGFloat)radius;

@end
