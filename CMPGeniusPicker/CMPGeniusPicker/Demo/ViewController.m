//
//  ViewController.m
//  CMPGeniusPicker
//
//  Created by Michael Radle on 13.07.15.
//  Copyright (c) 2015 Compience. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet CMPGeniusPickerView *geniusPicker;
@property (weak, nonatomic) IBOutlet UILabel *secondTitle;
@property (weak, nonatomic) IBOutlet UILabel *thirdTitle;
@property (weak, nonatomic) IBOutlet UILabel *firstTitle;

@property (nonatomic, strong) NSMutableArray *selection;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selection = [NSMutableArray array];
    [self.selection addObject:[NSNumber numberWithInteger:2]];
    [self.selection addObject:[NSNumber numberWithInteger:12]];
    [self.selection addObject:[NSNumber numberWithInteger:32]];
    
    [self.geniusPicker setDelegate:self];
    [self.geniusPicker setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - DataSource

- (NSInteger)numberOfItemsInStep:(NSInteger)step {
    return [[_selection objectAtIndex:step] integerValue];
}

- (NSInteger)numberOfSteps {
    return 3;
}

- (NSString *)itemTitleOfStepPath:(CMPStepPath *)stepPath {
    return [NSString stringWithFormat:@"%li", (long)[stepPath item]];
}

- (UIColor *)itemColorOfStepPath:(CMPStepPath *)stepPath {
    return [UIColor colorWithRed: 0.573 green: 0.968 blue: 0.632 alpha: 1];
}

- (NSInteger)selectItemOfStep:(NSInteger)step {
    return 0;
}

- (UIFont *)itemFontOfStepPath:(CMPStepPath *)stepPath {
    if (stepPath.step == 2) {
        return [UIFont boldSystemFontOfSize:8];
    }
    return [UIFont boldSystemFontOfSize:17];
}

#pragma mark - Delegate

- (void)itemDidSelectAtStepPath: (CMPStepPath *)stepPath {
    if ([stepPath step] == 0) {
        self.firstTitle.text = [NSString stringWithFormat:@"%li", [stepPath item]];
    } else if ([stepPath step] == 1) {
        self.secondTitle.text = [NSString stringWithFormat:@"%li", [stepPath item]];
    } else {
        self.thirdTitle.text = [NSString stringWithFormat:@"%li", [stepPath item]];
    }
    NSLog(@"item selected! %li step: %li", (long)[stepPath item], (long)[stepPath step]);
}

- (void)nextStepDidSelect:(NSInteger)step {
    NSLog(@"next Step!");
}

- (void)touchDidEnd {
    NSLog(@"Touched did end");
}

- (void)touchDidStart {
    NSLog(@"Touched did start");
}

- (IBAction)back:(UIButton *)sender {
    [self.geniusPicker backStep];
}

- (IBAction)next:(UIButton *)sender {
    [self.geniusPicker nextStep];
}

@end
