//
//  CMPGeniusItemView.h
//  CMPGeniusPicker
//
//  Created by Michael Radle on 15.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMPGeniusItemView : UIView

- (id)initWithFrame:(CGRect)frame
    backgroundColor: (UIColor *)backgroundColor
        borderWidth: (CGFloat)borderWidth
        borderColor: (UIColor *)borderColor
              title: (NSString *)title
               font: (UIFont *)font
          fontColor: (UIColor *)fontColor;

@end
