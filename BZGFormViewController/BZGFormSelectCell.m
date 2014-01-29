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
        
        self.textField.enabled = NO;
        self.textField.hidden = YES;
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
    self.button = [[UIButton alloc] init];
    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.button.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    self.button.tintColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    [self.button setTitleColor:BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR forState:UIControlStateNormal];
    self.button.titleLabel.textColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    self.button.titleLabel.font = BZG_FORMFIELD_TEXTFIELD_FONT;
    self.button.layer.cornerRadius = 8;
    self.button.layer.borderWidth = 1;
    self.button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.button.backgroundColor = [UIColor clearColor];
    [self.button addTarget:self action:@selector(openOptions:) forControlEvents:UIControlEventTouchUpInside];
    
    static UIImage *defaultImage = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(19, 10), NO, 0.0f);
        
        //// Color Declarations
        UIColor* color = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1];
        
        //// Bezier Drawing
        UIBezierPath* bezierPath = [UIBezierPath bezierPath];
        [bezierPath moveToPoint: CGPointMake(1.5, 0.5)];
        [bezierPath addCurveToPoint: CGPointMake(9.82, 8.51) controlPoint1: CGPointMake(10.46, 9.12) controlPoint2: CGPointMake(9.82, 8.51)];
        [bezierPath addLineToPoint: CGPointMake(17.5, 0.5)];
        [bezierPath addLineToPoint: CGPointMake(14.94, 0.5)];
        [bezierPath addLineToPoint: CGPointMake(9.82, 6.04)];
        [bezierPath addLineToPoint: CGPointMake(4.06, 0.5)];
        [bezierPath addLineToPoint: CGPointMake(1.5, 0.5)];
        [bezierPath closePath];
        bezierPath.lineJoinStyle = kCGLineJoinRound;
        
        [color setFill];
        [bezierPath fill];
        [color setStroke];
        bezierPath.lineWidth = 1;
        [bezierPath stroke];
        
        // get an image of the graphics context
        defaultImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // end the context
        UIGraphicsEndImageContext();
	});
    [self.button setImage:defaultImage forState:UIControlStateNormal];

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
    CGFloat buttonY = 4;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        buttonY = 12;
    }
    self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    CGRect buttonFrame = CGRectMake(buttonX,
                                    buttonY,
                                    self.bounds.size.width - buttonX - 10 - self.activityIndicatorView.frame.size.width,
                                    self.bounds.size.height-8);
    self.button.frame = buttonFrame;
    
    self.button.imageEdgeInsets = UIEdgeInsetsMake(4, buttonFrame.size.width - 29, 0, 0);
    
    
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
