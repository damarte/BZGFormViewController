//
//  BZGFormTextCell.m
//  Pods
//
//  Created by David Getapp on 27/01/14.
//
//

#import "BZGFormTextCell.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import "BZGFormInfoCell.h"
#import "Constants.h"

@implementation BZGFormTextCell

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        [self setDefaults];
        [self configureInfoCell];
        [self configureActivityIndicatorView];
        [self configureTextView];
        [self configureLabel];
        
    }
    return self;
}

- (id)initWithName:(NSString *)aName withPlaceholder:(NSString *) aPlaceHolder isRequired:(BOOL)required withKeyboard:(UIKeyboardType)keyboard
{
    self = [self init];
    if (self) {
        self.label.text = aName;
        self.textField.placeholder = aPlaceHolder;
        self.required = required;
        self.textField.keyboardType = keyboard;
        
        if(!self.required){
            self.validationState = BZGValidationStateValid;
        }
        
        [self configureBindings];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldTextDidEndEditing:)
                                                     name:UITextFieldTextDidEndEditingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldTextDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)configureTextView
{
    CGFloat textFieldX = self.bounds.size.width * 0.35;
    CGFloat textFieldY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        textFieldY = 12;
    }
    CGRect textFieldFrame = CGRectMake(textFieldX,
                                       textFieldY,
                                       self.bounds.size.width - textFieldX - self.activityIndicatorView.frame.size.width,
                                       self.bounds.size.height);
    self.textView = [[UITextView alloc] initWithFrame:textFieldFrame];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.textColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    self.textView.font = BZG_FORMFIELD_TEXTFIELD_FONT;
    self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textView];
}

- (void)configureBindings
{
    @weakify(self);
    
    RAC(self.textView, textColor) =
    [RACObserve(self, validationState) map:^UIColor *(NSNumber *validationState) {
        @strongify(self);
        if (self.textView.editing || self.textField.isFirstResponder) {
            return BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
        }
        switch (validationState.integerValue) {
            case BZGValidationStateInvalid:
                return BZG_FORMFIELD_TEXTFIELD_INVALID_COLOR;
                break;
            case BZGValidationStateValid:
            case BZGValidationStateValidating:
            case BZGValidationStateNone:
            default:
                return BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
                break;
        }
    }];
    
    RAC(self.activityIndicatorView, hidden) =
    [RACObserve(self, validationState) map:^NSNumber *(NSNumber *validationState) {
        @strongify(self);
        if (validationState.integerValue == BZGValidationStateValidating) {
            [self.activityIndicatorView startAnimating];
            return @NO;
        } else {
            [self.activityIndicatorView stopAnimating];
            return @YES;
        }
    }];
    
    RAC(self, accessoryType) =
    [RACObserve(self, validationState) map:^NSNumber *(NSNumber *validationState) {
        @strongify(self);
        if (validationState.integerValue == BZGValidationStateValid
            && !self.textField.editing) {
            return @(UITableViewCellAccessoryCheckmark);
        } else {
            return @(UITableViewCellAccessoryNone);
        }
    }];
}


@end
