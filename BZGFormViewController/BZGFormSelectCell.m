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

@interface BZGFormSelectCell () {
}

@property (nonatomic, strong) BZGFormOptionsViewController *optionPicker;
@property (nonatomic, strong) UIPopoverController *optionPickerPopover;

@end

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
    self.validationState = BZGValidationStateNone;
    self.shouldShowInfoCell = NO;
    self.options = [NSArray array];
    self.selected = nil;
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
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.button.tintColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    [self.button setTitleColor:BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR forState:UIControlStateNormal];
    self.button.titleLabel.textColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    self.button.titleLabel.font = BZG_FORMFIELD_TEXTFIELD_FONT;
    self.button.backgroundColor = [UIColor clearColor];
    [self.button addTarget:self action:@selector(openOptions:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];
}

- (void) openOptions:(id) sender
{
    if (_optionPicker == nil) {
        //Create the ColorPickerViewController.
        _optionPicker = [[BZGFormOptionsViewController alloc] initWithOptions:self.options];
        
        //Set this VC as the delegate.
        _optionPicker.delegate = self;
    }
    
    if (_optionPickerPopover == nil) {
        //The color picker popover is not showing. Show it.
        _optionPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_optionPicker];
        [_optionPickerPopover presentPopoverFromRect:self.button.bounds inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_optionPickerPopover dismissPopoverAnimated:YES];
        _optionPickerPopover = nil;
    }
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
    RAC(self.button, titleLabel.textColor) =
    [RACObserve(self, validationState) map:^UIColor *(NSNumber *validationState) {
        switch (validationState.integerValue) {
            case BZGValidationStateInvalid:
                return BZG_FORMFIELD_TEXTFIELD_INVALID_COLOR;
                break;
            case BZGValidationStateValid:
            case BZGValidationStateNone:
            default:
                return BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
                break;
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


#pragma mark - OptionPickerDelegate method
-(void)selectedOption:(NSDictionary *)newOption
{
    [self.button setTitle:[newOption objectForKey:@"name"] forState:UIControlStateNormal];
    
    //Dismiss the popover if it's showing.
    if (_optionPickerPopover) {
        [_optionPickerPopover dismissPopoverAnimated:YES];
        _optionPickerPopover = nil;
    }
}


@end
