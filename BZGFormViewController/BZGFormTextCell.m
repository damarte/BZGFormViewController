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

- (id)initWithName:(NSString *)aName isRequired:(BOOL)required withKeyboard:(UIKeyboardType)keyboard
{
    self = [self init];
    if (self) {
        self.label.text = aName;
        self.required = required;
        self.textField.keyboardType = keyboard;
        
        if(!self.required){
            self.validationState = BZGValidationStateValid;
        }
        
        [self configureBindings];
        
        self.textField.enabled = NO;
        self.textField.hidden = YES;
        
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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    return self;
}

- (void)configureTextView
{
    //Cell
    CGRect cellFrame = CGRectMake(0, 0, self.bounds.size.width, 108);
    self.frame = cellFrame;
    
    self.textView = [[UITextView alloc] init];
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor =  [[UIColor lightGrayColor] CGColor];
    self.textView.layer.cornerRadius = 8;
    self.textView.layer.masksToBounds = YES;
    self.textView.textColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    self.textView.font = BZG_FORMFIELD_TEXTFIELD_FONT;
    self.textView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.textView];
}

- (void)configureLabel
{
    self.label = [[UILabel alloc] init];
    self.label.font = BZG_FORMFIELD_LABEL_FONT;
    self.label.textColor = BZG_FORMFIELD_LABEL_COLOR;
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

- (void)configureBindings
{
    @weakify(self);
    
    RAC(self.textView, textColor) =
    [RACObserve(self, validationState) map:^UIColor *(NSNumber *validationState) {
        @strongify(self);
        if (self.textView.isFirstResponder) {
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
        if (validationState.integerValue == BZGValidationStateValid) {
            return @(UITableViewCellAccessoryCheckmark);
        } else {
            return @(UITableViewCellAccessoryNone);
        }
    }];
}

+ (BZGFormTextCell *)parentCellForTextView:(UITextView *)textView
{
    UIView *view = textView;
    while ((view = view.superview)) {
        if ([view isKindOfClass:[BZGFormTextCell class]]) break;
    }
    return (BZGFormTextCell *)view;
}

- (NSString *)value
{
    return self.textView.text;
}

- (void)redraw
{
    //TextView
    CGFloat textFieldX = 15;
    CGFloat textFieldY = 27;

    CGRect textFieldFrame = CGRectMake(textFieldX,
                                       textFieldY,
                                       self.bounds.size.width - 2*textFieldX - self.activityIndicatorView.frame.size.width,
                                       self.bounds.size.height - textFieldY);
    self.textView.frame = textFieldFrame;
    
    //Label
    CGFloat labelX = 15;
    CGRect labelFrame = CGRectMake(labelX,
                                   0,
                                   self.bounds.size.width-2*labelX-self.activityIndicatorView.frame.size.width,
                                   20);
    self.label.frame = labelFrame;
}

#pragma mark - UITextField notification selectors
// I'm using these notifications to flush the validation state signal.
// It works, but seems hacky. Is there a better way?

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if ([textView isEqual:self.textView]) {
        self.validationState = self.validationState;
        
        // Secure text fields clear on begin editing on iOS6+.
        // If it seems like the text field has been cleared,
        // invoke the text change delegate method again to ensure proper validation.
        if (textView.secureTextEntry && textView.text.length <= 1) {
            [self.textField.delegate textField:self.textField
                 shouldChangeCharactersInRange:NSMakeRange(0, textView.text.length)
                             replacementString:textView.text];
        }
    }
}

- (void)textFieldTextDidEndEditing:(NSNotification *)notification
{
    UITextView *textView = (UITextView *)notification.object;
    if ([textView isEqual:self.textField]) {
        self.validationState = self.validationState;
    }
}


@end
