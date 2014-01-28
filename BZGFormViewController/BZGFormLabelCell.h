//
//  BZGFormLabelCell.h
//  Pods
//
//  Created by David Getapp on 28/01/14.
//
//

#import "BZGFormFieldCell.h"

@interface BZGFormLabelCell : BZGFormFieldCell

@property (strong, nonatomic) UILabel *labelValue;

- (id)initWithName:(NSString *)aName andValue:(NSString *)aValue;

@end
