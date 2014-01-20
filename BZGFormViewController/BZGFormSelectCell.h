//
//  BZGFormSelectCell.h
//  Pods
//
//  Created by David Getapp on 20/01/14.
//
//

#import <UIKit/UIKit.h>
#import "BZGFormInfoCell.h"

typedef NS_ENUM(NSInteger, BZGValidationSelectState) {
    BZGValidationSelectStateInvalid,
    BZGValidationSelectStateValid,
    BZGValidationSelectStateNone
};

@interface BZGFormSelectCell : UITableViewCell <UIPopoverControllerDelegate>

/*typedef void (^voidEditingEventBlock)(BZGFormSelectCell *cell, NSString *text);
typedef BOOL (^boolEditingEventBlock)(BZGFormSelectCell *cell, NSString *text);*/

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIButton *button;

/// The current validation state. Default is BZGValidationStateNone.
@property (assign, nonatomic) BZGValidationSelectState validationState;

/// The info cell displayed below this cell when shouldShowInfoCell is true.
@property (strong, nonatomic) BZGFormInfoCell *infoCell;

/// A value indicating whether or not the cell's info cell should be shown.
@property (assign, nonatomic) BOOL shouldShowInfoCell;

/**
 * Returns the parent BZGFormSelectCell for the given text field. If no cell is found, returns nil.
 *
 * @param button A UIButton instance that may or may not belong to this BZGFormSelectCell instance.
 */
+ (BZGFormSelectCell *)parentCellForButton:(UIButton *)button;

@end
