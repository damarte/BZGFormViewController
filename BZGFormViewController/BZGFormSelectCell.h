//
//  BZGFormSelectCell.h
//  Pods
//
//  Created by David Getapp on 20/01/14.
//
//

#import "BZGFormInfoCell.h"
#import "BZGFormFieldCell.h"
#import "BZGFormOptionsViewController.h"

@class BZGFormSelectCell;

@protocol SelectCellDelegate <NSObject>
@required
-(void)selectedOption:(NSDictionary *)newOption withCell:(BZGFormSelectCell *)cell;
@end

@interface BZGFormSelectCell : BZGFormFieldCell <OptionPickerDelegate, UIPopoverControllerDelegate>

typedef void (^boolSelectEventBlock)(BZGFormSelectCell *cell, NSDictionary *value);

@property (nonatomic, strong) id<SelectCellDelegate> delegate;
@property (strong, nonatomic) NSString *placeholder;
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSDictionary *optionSelected;

/**
 * The block called before the text field's text changes.
 * The block's text parameter is the new text. Return NO if the text shouldn't change.
 */
@property (copy, nonatomic) boolSelectEventBlock shouldChangeBlock;

/**
 * Returns the parent BZGFormSelectCell for the given text field. If no cell is found, returns nil.
 *
 * @param button A UIButton instance that may or may not belong to this BZGFormSelectCell instance.
 */
+ (BZGFormSelectCell *)parentCellForButton:(UIButton *)button;

//General constructor
- (id)initWithName:(NSString *)aName withPlaceholder:(NSString *) aPlaceHolder isRequired:(BOOL)required withOptions:(NSArray *)options andSelected:(NSString *)selected;

@end
