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
        
    }
    return self;
}

- (id)initWithName:(NSString *)aName withPlaceholder:(NSString *) aPlaceHolder isRequired:(BOOL)required withOptions:(NSArray *)options andSelected:(NSString *)selected
{
    self = [self init];
    if (self) {
        self.label.text = aName;
        self.placeholder = aPlaceHolder;
        [self.button setTitle:self.placeholder forState:UIControlStateNormal];
        self.required = required;
        
        if(required){
            self.options = options;
        }
        else{
            self.validationState = BZGValidationStateValid;
            NSMutableArray *values = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Ninguno", nil), @"name", @"0", @"id", nil]];
            [values addObjectsFromArray:options];
            self.options = values;
        }
        
        if(selected){
            NSInteger i = 0;
            for (NSDictionary *value in self.options) {
                if([[value objectForKey:@"id"] isEqualToString:selected]){
                    self.optionSelected = [self.options objectAtIndex:i];
                }
                i++;
            }
            
            [self.button setTitle:[self.optionSelected objectForKey:@"name"] forState:UIControlStateNormal];
        }
        
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
    [super setDefaults];
    self.options = [NSArray array];
    self.optionSelected = nil;
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
        NSString *selected = nil;
        if(self.optionSelected){
            selected = [self.optionSelected objectForKey:@"id"];
        }
        _optionPicker = [[BZGFormOptionsViewController alloc] initWithOptions:self.options andSelected:selected];
        _optionPicker.delegate = self;
    }
    
    if (_optionPickerPopover == nil) {
        _optionPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_optionPicker];
        _optionPickerPopover.delegate = self;
    }
    
    [_optionPickerPopover presentPopoverFromRect:self.button.bounds inView:self permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    
    RAC(self, accessoryType) =
    [RACObserve(self, validationState) map:^NSNumber *(NSNumber *validationState) {
        if (validationState.integerValue == BZGValidationStateValid) {
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

- (NSString *)value
{
    return [self.optionSelected objectForKey:@"id"];
}

- (void)redraw
{
    //Button
    CGFloat buttonX = self.bounds.size.width * 0.35;
    CGFloat buttonY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        buttonY = 12;
    }
    self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    CGRect buttonFrame = CGRectMake(buttonX,
                                    buttonY,
                                    self.bounds.size.width - buttonX,
                                    self.bounds.size.height);
    self.button.frame = buttonFrame;
    
    //Label
    CGFloat labelX = 10;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        labelX = 15;
    }
    CGRect labelFrame = CGRectMake(labelX,
                                   0,
                                   self.button.frame.origin.x - labelX - 5,
                                   self.bounds.size.height);
    self.label.frame = labelFrame;
}


#pragma mark - OptionPickerDelegate
-(void)selectedOption:(NSDictionary *)newOption
{
    if(newOption){
        [self.button setTitle:[newOption objectForKey:@"name"] forState:UIControlStateNormal];
    }
    else{
        [self.button setTitle:self.placeholder forState:UIControlStateNormal];
    }
        
    self.optionSelected = newOption;
    
    [self.delegate selectedOption:newOption withCell:self];
    
    self.validationState = self.validationState;
    
    //Dismiss the popover if it's showing.
    if (_optionPickerPopover) {
        [_optionPickerPopover dismissPopoverAnimated:YES];
        _optionPickerPopover = nil;
    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController{
    [self.delegate selectedOption:self.optionPicker.selected withCell:self];
    
    self.validationState = self.validationState;
}


@end
