//
//  CMPGeniusPickerView.m
//  CMPGeniusPicker
//
//  Created by Michael Radle on 13.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import "CMPGeniusPickerView.h"
#import "CMPMathUtil.h"
#import "CMPGeniusItemView.h"
#define PATH @"%f_%f"

CGFloat const kBorder = 5;
CGFloat const kDistance = 8;
CGFloat const kMouseIconSize = 40;
CGFloat const kMiddlePointSize = 20;
CGFloat const kScaleMin = 0.5;
CGFloat const kScaleMax = 1.4;
CGFloat const kAnimationDuration = 0.4;

@implementation CMPStepPath

+ (CMPStepPath *)step: (NSInteger)step item: (NSInteger)item {
    CMPStepPath *stepPath = [CMPStepPath new];
    stepPath.step = step;
    stepPath.item = item;
    return stepPath;
}

@end

@interface CMPGeniusPickerView ()

/// SubViews
@property (nonatomic) UIView *markerView;
@property (nonatomic) UIView *middleLine;
@property (nonatomic) UIView *mainView;
@property (nonatomic) UIView *lastMainView;
/// Layer
@property (nonatomic) NSInteger numberOfStep;
@property (nonatomic) NSInteger currentStep;
@property (nonatomic) NSArray *itemViewPositions;
@property (nonatomic) NSDictionary *stepPaths;
@property (nonatomic) CMPStepPath *selectedPath;

@end

@implementation CMPGeniusPickerView

- (void)drawRect:(CGRect)rect {
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* gray = [UIColor colorWithRed: 0.969 green: 0.969 blue: 0.969 alpha: 1];
    
    //// Shadow Declarations
    NSShadow* shadow = [[NSShadow alloc] init];
    [shadow setShadowColor: UIColor.blackColor];
    [shadow setShadowOffset: CGSizeMake(0.1, -0.1)];
    [shadow setShadowBlurRadius: 6];
    
    //// Variable Declarations
    CGFloat borderWidth = rect.size.width - (kBorder * 2);
    CGFloat borderHeight = rect.size.width - (kBorder * 2);
    
    //// Oval Drawing
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect:
                              CGRectMake(kBorder, kBorder, borderWidth, borderHeight)];
    [gray setFill];
    [ovalPath fill];
    
    ////// Oval Inner Shadow
    CGContextSaveGState(context);
    UIRectClip(ovalPath.bounds);
    CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
    
    CGContextSetAlpha(context, CGColorGetAlpha([shadow.shadowColor CGColor]));
    CGContextBeginTransparencyLayer(context, NULL);
    {
        UIColor* opaqueShadow = [shadow.shadowColor colorWithAlphaComponent: 1];
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [opaqueShadow CGColor]);
        CGContextSetBlendMode(context, kCGBlendModeSourceOut);
        CGContextBeginTransparencyLayer(context, NULL);
        
        [opaqueShadow setFill];
        [ovalPath fill];
        
        CGContextEndTransparencyLayer(context);
    }
    CGContextEndTransparencyLayer(context);
    CGContextRestoreGState(context);
    
    [UIColor.whiteColor setStroke];
    ovalPath.lineWidth = 0;
    [ovalPath stroke];
 
    /// Mask
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    CGFloat width = self.frame.size.width - (kBorder * 2);
    CGFloat height = self.frame.size.height - (kBorder * 2);
    CGRect maskRect = CGRectMake(kBorder, kBorder, width, height);
    CGPathRef path = CGPathCreateWithRoundedRect(maskRect, width / 2, height / 2, NULL);
    maskLayer.path = path;
    self.layer.mask = maskLayer;
    /// Init steps
    self.numberOfStep = [_dataSource numberOfSteps];
    self.currentStep = 0;
    /// Middle point
    [self addSubview:[self createMiddlePoint]];
    [self reloadWithAnimation:GeniusAnimationNext];
}

/**
 *  Reload the the genius picker view.
 *
 *  @param animation The direction of the animation of items.
 */
- (void)reloadWithAnimation: (CMPGeniusAnimation)animation
{
    /// MainView
    CGRect mainFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    _mainView = [[UIView alloc] initWithFrame:mainFrame];
    [self addSubview:_mainView];
    if (animation == GeniusAnimationNext) {
        self.mainView.transform = CGAffineTransformMakeScale(kScaleMin, kScaleMin);
    } else {
        self.mainView.transform = CGAffineTransformMakeScale(kScaleMax, kScaleMax);
    }
    self.mainView.alpha = 0.0;
    
    NSMutableArray *itemViewPositions = [NSMutableArray array];
    NSInteger items = [self.dataSource numberOfItemsInStep: self.currentStep];
    CGFloat itemSize = [self calcSizeOfItem];
    NSMutableDictionary *stepPaths = [NSMutableDictionary new];
    for (int item = 0; item < items; item++) {
        CMPStepPath *stepPath = [CMPStepPath step:_currentStep
                                             item:item];
        CGPoint xy = [self calcPointOfItem: item
                              itemSize: itemSize];
        CGRect frame = CGRectMake(xy.x + (kDistance / 2),
                                  xy.y + (kDistance / 2),
                                  itemSize - kDistance,
                                  itemSize - kDistance);
        CMPGeniusItemView *itemView = [self createItemViewWithFrame:frame
                                                           stepPath:stepPath];
        /// Save item view position
        [itemViewPositions addObject:[NSValue valueWithCGRect:frame]];
        /// Save step path
        [stepPaths setObject: stepPath
                      forKey: [NSString stringWithFormat:PATH, frame.origin.x, frame.origin.y]];
        /// Select Item
        if ([_dataSource selectItemOfStep:_currentStep] == item) {
            self.markerView = [self createMarkerWithFrame: frame];
            self.middleLine = [self createMarkerLine];
            [self drawMarkerLine];
            [_mainView addSubview:self.markerView];
            [_mainView addSubview:self.middleLine];
        }
        /// Add Item
        [_mainView addSubview: itemView];
    }
    self.itemViewPositions = itemViewPositions;
    self.stepPaths = stepPaths;
    /// Animation
    if (_completionHandler) {
        self.completionHandler(NO);
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.mainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        self.mainView.alpha = 1.0;
    } completion:^(BOOL finished) {
        for (UIView *subView in [_lastMainView subviews]) {
            [subView removeFromSuperview];
        }
        if (_completionHandler) {
            self.completionHandler(YES);
        }
        self.lastMainView = self.mainView;
    }];
}


#pragma mark - Subviews

/**
 *  Creates an item view. The values will be load from the data source.
 *
 *  @param frame     Item frame.
 *  @param stepPath  The current step path.
 *
 *  @return Item view.
 */
- (CMPGeniusItemView *)createItemViewWithFrame: (CGRect)frame
                                      stepPath: (CMPStepPath *)stepPath

{
    /// Background color
    UIColor *bgColor = [UIColor colorWithRed: 0.573 green: 0.968 blue: 0.632 alpha: 1];
    if ([_dataSource respondsToSelector:@selector(itemColorOfStepPath:)]) {
        bgColor = [_dataSource itemColorOfStepPath:stepPath];
    }
    /// Border width
    CGFloat borderWidth = 2.0f;
    if ([_dataSource respondsToSelector:@selector(itemBorderOfStepPath:)]) {
        borderWidth = [_dataSource itemBorderOfStepPath:stepPath];
    }
    /// Border color
    UIColor *borderColor = [UIColor whiteColor];
    if ([_dataSource respondsToSelector:@selector(itemBorderColorOfStepPath:)]) {
        borderColor = [_dataSource itemBorderColorOfStepPath:stepPath];
    }
    /// Title
    NSString *title = @"";
    if ([_dataSource respondsToSelector:@selector(itemTitleOfStepPath:)]) {
        title = [_dataSource itemTitleOfStepPath:stepPath];
    }
    /// Font of the title
    UIFont *font = [UIFont boldSystemFontOfSize: 17];
    if ([_dataSource respondsToSelector:@selector(itemFontOfStepPath:)]) {
        font = [_dataSource itemFontOfStepPath:stepPath];
    }
    UIColor *fontColor = [UIColor whiteColor];
    if ([_dataSource respondsToSelector:@selector(itemFontColorOfStepPath:)]) {
        fontColor = [_dataSource itemFontColorOfStepPath:stepPath];
    }
    return [[CMPGeniusItemView alloc] initWithFrame: frame
                                    backgroundColor: bgColor
                                        borderWidth: borderWidth
                                        borderColor: borderColor
                                              title: title
                                               font: font
                                          fontColor: fontColor];
}

/**
 *  Creates a item marker view.
 *
 *  @param frame Frame of the item.
 *
 *  @return An oval UIView.
 */
- (UIView *)createMarkerWithFrame: (CGRect)frame
{
    CGFloat startX = frame.origin.x + (frame.size.width / 2);
    CGFloat startY = frame.origin.y + (frame.size.height / 2);
    CGFloat size = (frame.size.width + kDistance);
    UIView *mouse;
    if (size < kMouseIconSize) {
        CGFloat posX = startX - (kMouseIconSize / 2);
        CGFloat posY = startY - (kMouseIconSize / 2);
        mouse = [[UIView alloc] initWithFrame:
                         CGRectMake(posX, posY, kMouseIconSize, kMouseIconSize)];
        mouse.layer.cornerRadius = (kMouseIconSize / 2);
    } else {
        CGFloat postX = startX - (size / 2);
        CGFloat postY = startY - (size / 2);
        mouse = [[UIView alloc] initWithFrame:
                         CGRectMake(postX, postY, size, size)];
        mouse.layer.cornerRadius = (size / 2);
    }
    mouse.layer.masksToBounds = YES;
    mouse.backgroundColor = [UIColor colorWithRed: 0.573
                                            green: 0.968
                                             blue: 0.632
                                            alpha: 0.565];
    return mouse;
}

/**
 *  Middle point.
 *
 *  @return UIView.
 */
- (UIView *)createMiddlePoint {
    CGFloat xPos = (self.frame.size.width / 2) - (kMiddlePointSize / 2);
    CGFloat yPos = (self.frame.size.height / 2) - (kMiddlePointSize / 2);
    CGRect frame = CGRectMake(xPos, yPos, kMiddlePointSize, kMiddlePointSize);
    UIView *middlePoint = [[UIView alloc] initWithFrame:frame];
    middlePoint.layer.cornerRadius = kMiddlePointSize / 2;
    middlePoint.backgroundColor = [UIColor whiteColor];
    return middlePoint;
}

/**
 *  Creates a View for the marker line.
 *
 *  @return A clear view.
 */
- (UIView *)createMarkerLine {
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    return [[UIView alloc] initWithFrame:frame];
}

/**
 *  Draws the line between the middle point and marker view.
 */
- (void)drawMarkerLine {
    self.middleLine.layer.sublayers = nil;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat xSPos = self.frame.size.width / 2;
    CGFloat ySPos = self.frame.size.height / 2;
    [path moveToPoint:CGPointMake(xSPos, ySPos)];
    CGFloat xEPos = self.markerView.frame.origin.x + (self.markerView.frame.size.width / 2);
    CGFloat yEPos = self.markerView.frame.origin.y + (self.markerView.frame.size.height / 2);
    [path addLineToPoint:CGPointMake(xEPos, yEPos)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 3.0;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    [self.middleLine.layer addSublayer:shapeLayer];
}


#pragma mark - Calculation

/**
 *  Calculates the maximum size of the items by the number of the items.
 *
 *  @return Size of an item.
 */
- (CGFloat)calcSizeOfItem {
    NSInteger itemCount = [self.dataSource numberOfItemsInStep:self.currentStep];
    CGFloat radius = (self.frame.size.width - kBorder) / 2 - kDistance;
    return [CMPMathUtil radiusRelationOfMainRadius:radius itemCount:itemCount];
}

/**
 *  Calculates the start position of the items.
 *
 *  @param item         The current item.
 *  @param itemSize     The maximum size of the item.
 *
 *  @return X and Y position of the item.
 */
- (CGPoint)calcPointOfItem: (NSInteger)item
                  itemSize: (CGFloat)itemSize
{
    NSInteger itemCount = [self.dataSource numberOfItemsInStep:self.currentStep];
    CGFloat radius = (self.frame.size.width / 2) - (itemSize / 2) - kDistance - kBorder;
    CGFloat angle = (360.0f / (CGFloat)itemCount) * item;
    CGPoint itemPoint = [CMPMathUtil xyPositionOfAngle:angle radius:radius];
    CGFloat margin = (kDistance + kBorder);
    return CGPointMake(itemPoint.x + margin, itemPoint.y + margin);
}


#pragma mark - Mouse Event

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint tLocation =[[touches anyObject] locationInView:self];
    [self selectItemOnLocation:tLocation];
}

/**
 *  Updates the marker and call the delegate.
 *
 *  @param tLocation The position of the touch point.
 */
- (void)selectItemOnLocation: (CGPoint)tLocation {
    for (int i = 0; i < [_itemViewPositions count]; i++) {
        CGRect frame = [[_itemViewPositions objectAtIndex:i] CGRectValue];
        CGFloat minX = frame.origin.x;
        CGFloat maxX = frame.origin.x + frame.size.width;
        CGFloat minY = frame.origin.y;
        CGFloat maxY = frame.origin.y + frame.size.height;
        if (tLocation.x >= minX && tLocation.x <= maxX && tLocation.y >= minY && tLocation.y <= maxY) {
            CGFloat xPos = frame.origin.x + (frame.size.width / 2) - (self.markerView.frame.size.width / 2);
            CGFloat yPos = frame.origin.y + (frame.size.height / 2) - (self.markerView.frame.size.height / 2);
            CGRect newFrame = CGRectMake(xPos, yPos, self.markerView.frame.size.width, self.markerView.frame.size.height);
            if (self.markerView.frame.origin.x != newFrame.origin.x && self.markerView.frame.origin.y != newFrame.origin.y) {
                self.markerView.frame = newFrame;
                self.selectedPath = [_stepPaths valueForKey:[NSString stringWithFormat:PATH,
                                                             frame.origin.x, frame.origin.y]];
                if ([_delegate respondsToSelector:@selector(itemDidSelectAtStepPath:)]) {
                    [_delegate itemDidSelectAtStepPath:_selectedPath];
                }
                [self drawMarkerLine];
            }
            return;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint tLocation =[[touches anyObject] locationInView:self];
    [self selectItemOnLocation:tLocation];
    if (_currentStep < [_dataSource numberOfSteps]) {
        [self nextStep];
        if ([_delegate respondsToSelector:@selector(nextStepDidSelect:)]) {
            [_delegate nextStepDidSelect:_currentStep];
        }
    }
}

#pragma mark - Next step

/**
 *  Go back to the last step.
 */
- (void)backStep {
    if (_currentStep > 0) {
        self.currentStep -= 1;
        self.lastMainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration: kAnimationDuration
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             self.lastMainView.transform = CGAffineTransformMakeScale(kScaleMin, kScaleMin);
                             self.lastMainView.alpha = 0.0;
                         } completion: nil];
        [self reloadWithAnimation: GeniusAnimationBack];
    }
}

/**
 *  Go the next step.
 */
- (void)nextStep {
    if ([_dataSource numberOfSteps] > (self.currentStep + 1)) {
        self.currentStep += 1;
        UIView *mainView = self.lastMainView;
        mainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration: kAnimationDuration
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             mainView.transform = CGAffineTransformMakeScale(kScaleMax, kScaleMax);
                             mainView.alpha = 0.0;
                         } completion: nil];
        [self reloadWithAnimation: GeniusAnimationNext];
    }
}

/**
 *  Go the step .
 *
 *  @param step The desired step.
 */
- (void)goToStep: (NSInteger)step {
    if ([_dataSource numberOfSteps] > step && _currentStep != step && step >= 0) {
        _currentStep = step;
        self.lastMainView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        [UIView animateWithDuration: kAnimationDuration
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             if (step > _currentStep) {
                                 self.lastMainView.transform = CGAffineTransformMakeScale(kScaleMax, kScaleMax);
                             } else {
                                 self.lastMainView.transform = CGAffineTransformMakeScale(kScaleMin, kScaleMin);
                             }
                             self.lastMainView.alpha = 0.0;
                         } completion: nil];
        if (step > _currentStep) {
            [self reloadWithAnimation: GeniusAnimationNext];
        } else {
            [self reloadWithAnimation: GeniusAnimationBack];
        }
    }
}

@end