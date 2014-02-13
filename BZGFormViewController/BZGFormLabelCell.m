//
//  BZGFormLabelCell.m
//  Pods
//
//  Created by David Getapp on 28/01/14.
//
//

#import "BZGFormLabelCell.h"
#import "Constants.h"

@implementation BZGFormLabelCell

- (id)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        [self setDefaults];
        [self configureValueLabel];
        [self configureLabel];
        
    }
    return self;
}

- (id)initWithName:(NSString *)aName andValue:(NSString *)aValue
{
    self = [self init];
    if (self) {
        self.label.text = aName;
        self.required = NO;
        self.labelValue.text = aValue;
        self.textField.enabled = NO;
        self.textField.hidden = YES;
        self.validationState = BZGValidationStateValid;
    }
    return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super init];
    return self;
}

- (void)configureValueLabel
{
    self.labelValue = [[UILabel alloc] init];
    self.labelValue.textColor = BZG_FORMFIELD_TEXTFIELD_NORMAL_COLOR;
    self.labelValue.font = BZG_FORMFIELD_TEXTFIELD_FONT;
    self.labelValue.backgroundColor = [UIColor clearColor];
    [self addSubview:self.labelValue];
}

+ (BZGFormLabelCell *)parentCellForLabel:(UILabel *)label
{
    UIView *view = label;
    while ((view = view.superview)) {
        if ([view isKindOfClass:[BZGFormLabelCell class]]) break;
    }
    return (BZGFormLabelCell *)view;
}

- (NSString *)value
{
    return self.labelValue.text;
}

- (void)redraw
{
    //TextField
    CGFloat textFieldX = self.bounds.size.width * 0.35;
    CGFloat textFieldY = 0;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
        textFieldY = 12;
    }
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    CGRect textFieldFrame = CGRectMake(textFieldX,
                                       textFieldY,
                                       self.bounds.size.width - textFieldX - self.activityIndicatorView.frame.size.width,
                                       self.bounds.size.height);
    self.labelValue.frame = textFieldFrame;
    
    //Label
    CGFloat labelX = 15;
    CGRect labelFrame = CGRectMake(labelX,
                                   0,
                                   self.labelValue.frame.origin.x - labelX - 5,
                                   self.bounds.size.height);
    self.label.frame = labelFrame;
}

@end
