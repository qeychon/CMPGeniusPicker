# CMPGeniusPicker

# Demo

![CMPGeniusPicker](https://raw.githubusercontent.com/qeychon/CMPGeniusPicker/master/demo.gif)


## Installation

To install it, simply add the following line to your Podfile:

```ruby
pod 'CMPGeniusPicker', :git => 'git@github.com:qeychon/CMPGeniusPicker.git'
```
or copy the sources files in to the project folder.

## Usage

#### 1. Modify storyboard 
First you have to modify the storyboard. The class of the desired UIView has to be replaced by the class `CMPGeniusPickerView`.

#### 2. Delegate and DataSource 
Then you have to implement the `Delegate` and `DataSource` of the class `CMPGeniusPickerView`. The concept should be known of UITableView.

```objective-c
@interface ViewController : UIViewController <CMPGeniusPickerDelegate, CMPGeniusPickerDataSource>
@end
```

#### 3. DataSource
With the help of the `DataSource` the content of CMPGeniusPicker is defined. The `CMPGeniusPickerView` has steps and items. A step contains several items. It will automatically switch to the next level, if an item has been selected.
Therefore, the following data must be defined:

+ Maximal number of the steps.
+ Number of the items in the specified step.
+ The selected item at the beginning in a step.

```objective-c
- (NSInteger)numberOfSteps;
- (NSInteger)numberOfItemsInStep: (NSInteger)step;
- (NSInteger)selectItemOfStep: (NSInteger)step;
```

In addition, the appearance of the items can be defined. In each stage, an item can be designed according to your requirements.
 
```objective-c
- (UIColor *)itemColorOfStepPath: (CMPStepPath *)stepPath;
- (CGFloat)itemBorderOfStepPath: (CMPStepPath *)stepPath;
- (UIColor *)itemBorderColorOfStepPath: (CMPStepPath *)stepPath;
- (NSString *)itemTitleOfStepPath: (CMPStepPath *)stepPath;
- (UIFont *)itemFontOfStepPath: (CMPStepPath *)stepPath;
- (UIColor *)itemFontColorOfStepPath: (CMPStepPath *)stepPath;
```
The definition are optional.

#### 4. Delegate
There exists two events:

+ The selection of the item.
+ The change to the next step.

```objective-c
- (void)itemDidSelectAtStepPath: (CMPStepPath *)stepPath;
@optional
- (void)nextStepDidSelect: (NSInteger)step;
```
#### 5. Additional
The change to the respective stages is performed automatically after selecting an item. However, it can be changed directly on the stage. 
With the following functions:

+ `backStep`: Go back to the last step.
+ `nextStep`: Go to the next step.
+ `goToStep: (NSInteger)step `: Go to the specified step.

## License

CMPGeniusPicker is available under the MIT license. See the LICENSE file for more info.
