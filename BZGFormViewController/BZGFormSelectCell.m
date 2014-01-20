//
//  BZGFormSelectCell.m
//  Pods
//
//  Created by David Getapp on 20/01/14.
//
//

#import "BZGFormSelectCell.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import "BZGFormInfoCell.h"
#import "Constants.h"

@implementation BZGFormSelectCell

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        [self setDefaults];
        [self configureInfoCell];
        [self configureButton];
        [self configureLabel];
        [self configureBindings];
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    return self;
}

- (void)setDefaults
{
    self.backgroundColor = BZG_FORMFIELD_BACKGROUND_COLOR;
    self.textLabel.hidden = YES;
    self.detailTextLabel.hidden = YES;
    self.imageView.hidden = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.validationState = BZGValidationSelectStateNone;
    self.shouldShowInfoCell = NO;
}

- (void)configureInfoCell
{
    self.infoCell = [[BZGFormInfoCell alloc] init];
}

- (void)configureButton
{
    CGFloat textFieldX = self.bounds.size.width * 0.35;
    CGFloat textFieldY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        textFieldY = 12;
    }
    self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    CGRect buttonFrame = CGRectMake(textFieldX,
                                       textFieldY,
                                       self.bounds.size.width - textFieldX,
                                       self.bounds.size.height);
    self.button = [[UIButton alloc] initWithFrame:buttonFrame];
    self.button.titleLabel.textColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    self.button.titleLabel.font = BZG_FORMFIELD_TEXTFIELD_FONT;
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];
}

- (void)configureLabel
{
    CGFloat labelX = 10;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        labelX = 15;
    }
    CGRect labelFrame = CGRectMake(labelX,
                                   0,
                                   self.button.frame.origin.x - labelX - 5,
                                   self.bounds.size.height);
    self.label = [[UILabel alloc] initWithFrame:labelFrame];
    self.label.font = BZG_FORMFIELD_LABEL_FONT;
    self.label.textColor = BZG_FORMFIELD_LABEL_COLOR;
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

- (void)configureBindings
{
    @weakify(self);
    
    RAC(self.button, titleLabel.textColor) =
    [RACObserve(self, validationState) map:^UIColor *(NSNumber *validationState) {
        @strongify(self);
        /*if (self.textField.editing || self.textField.isFirstResponder) {
            return BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
        }*/
        switch (validationState.integerValue) {
            case BZGValidationSelectStateInvalid:
                return BZG_FORMFIELD_TEXTFIELD_INVALID_COLOR;
                break;
            case BZGValidationSelectStateValid:
            case BZGValidationSelectStateNone:
            default:
                return BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
                break;
        }
    }];
    
    RAC(self, accessoryType) =
    [RACObserve(self, validationState) map:^NSNumber *(NSNumber *validationState) {
        @strongify(self);
        if (validationState.integerValue == BZGValidationSelectStateValid) {
            return @(UITableViewCellAccessoryCheckmark);
        } else {
            return @(UITableViewCellAccessoryNone);
        }
    }];
}


+ (BZGFormSelectCell *)parentCellForButton:(UIButton *)button
{
    UIView *view = button;
    while ((view = view.superview)) {
        if ([view isKindOfClass:[BZGFormSelectCell class]]) break;
    }
    return (BZGFormSelectCell *)view;
}


#pragma mark - UITextField notification selectors


@end
