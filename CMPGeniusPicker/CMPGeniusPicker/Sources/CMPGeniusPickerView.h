//
//  CMPGeniusPickerView.h
//  CMPGeniusPicker
//
//  Created by Michael Radle on 13.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CMPGeniusAnimation) {
    GeniusAnimationBack,
    GeniusAnimationNext
};

@interface CMPStepPath : NSObject

@property (nonatomic) NSInteger step;
@property (nonatomic) NSInteger item;

+ (CMPStepPath *)step: (NSInteger)step item: (NSInteger)item;

@end

@protocol CMPGeniusPickerDataSource <NSObject>

- (NSInteger)numberOfSteps;
- (NSInteger)numberOfItemsInStep: (NSInteger)step;
- (NSInteger)selectItemOfStep: (NSInteger)step;

@optional
- (UIColor *)itemColorOfStepPath: (CMPStepPath *)stepPath;
- (CGFloat)itemBorderOfStepPath: (CMPStepPath *)stepPath;
- (UIColor *)itemBorderColorOfStepPath: (CMPStepPath *)stepPath;
- (NSString *)itemTitleOfStepPath: (CMPStepPath *)stepPath;
- (UIFont *)itemFontOfStepPath: (CMPStepPath *)stepPath;
- (UIColor *)itemFontColorOfStepPath: (CMPStepPath *)stepPath;
@end

@protocol CMPGeniusPickerDelegate <NSObject>

- (void)itemDidSelectAtStepPath: (CMPStepPath *)stepPath;
@optional
- (void)nextStepDidSelect: (NSInteger)step;
- (void)touchDidStart;
- (void)touchDidEnd;

@end

typedef void (^CompletionHandler)(BOOL);

@interface CMPGeniusPickerView : UIView

@property (nonatomic, weak) id<CMPGeniusPickerDataSource> dataSource;
@property (nonatomic, weak) id<CMPGeniusPickerDelegate> delegate;
@property (nonatomic, strong) CompletionHandler completionHandler;

- (void)reloadWithAnimation: (CMPGeniusAnimation)animation;
- (void)backStep;
- (void)nextStep;
- (void)goToStep: (NSInteger)step;

@end
