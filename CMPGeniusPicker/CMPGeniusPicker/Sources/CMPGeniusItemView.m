//
//  CMPGeniusItemView.m
//  CMPGeniusPicker
//
//  Created by Michael Radle on 15.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import "CMPGeniusItemView.h"

@implementation CMPGeniusItemView

- (id)initWithFrame:(CGRect)frame
    backgroundColor: (UIColor *)backgroundColor
        borderWidth: (CGFloat)borderWidth
        borderColor: (UIColor *)borderColor
              title: (NSString *)title
               font: (UIFont *)font
          fontColor: (UIColor *)fontColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.width / 2;
        self.layer.masksToBounds = YES;
        self.backgroundColor = backgroundColor;
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = borderColor.CGColor;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:
                          CGRectMake(0,
                                     0,
                                     frame.size.width,
                                     frame.size.width)];
        titleLabel.text = title;
        titleLabel.textColor = fontColor;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = font;
        [self addSubview:titleLabel];
    }
    return self;
}

@end
