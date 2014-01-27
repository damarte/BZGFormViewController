//
//  BZGFormTextCell.h
//  Pods
//
//  Created by David Getapp on 27/01/14.
//
//

#import "BZGFormInfoCell.h"
#import "BZGFormFieldCell.h"
#import "BZGFormOptionsViewController.h"

@interface BZGFormTextCell : BZGFormFieldCell <UITextViewDelegate>

@property (strong, nonatomic) UITextView *textView;

@end
