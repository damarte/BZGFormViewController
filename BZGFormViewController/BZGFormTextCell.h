//
//  BZGFormTextCell.h
//  Pods
//
//  Created by David Getapp on 27/01/14.
//
//

#import "BZGFormInfoCell.h"
#import "BZGFormFieldCell.h"

@interface BZGFormTextCell : BZGFormFieldCell <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;

- (id)initWithName:(NSString *)aName isRequired:(BOOL)required withKeyboard:(UIKeyboardType)keyboard;

@end
