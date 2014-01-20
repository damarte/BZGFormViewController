//
//  BZGFormSelectCell.h
//  Pods
//
//  Created by David Getapp on 20/01/14.
//
//

#import <UIKit/UIKit.h>
#import "BZGFormInfoCell.h"
#import "BZGFormFieldCell.h"
#import "BZGFormOptionsViewController.h"


@interface BZGFormSelectCell : BZGFormFieldCell <OptionPickerDelegate>

typedef BOOL (^boolSelectEventBlock)(BZGFormSelectCell *cell, NSDictionary *value);

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;

@property (strong, nonatomic) NSArray *options;
@property (strong, nonatomic) NSDictionary *selected;

/// The current validation state. Default is BZGValidationStateNone.
@property (assign, nonatomic) BZGValidationState validationState;

/// The info cell displayed below this cell when shouldShowInfoCell is true.
@property (strong, nonatomic) BZGFormInfoCell *infoCell;

/// A value indicating whether or not the cell's info cell should be shown.
@property (assign, nonatomic) BOOL shouldShowInfoCell;



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

@end
