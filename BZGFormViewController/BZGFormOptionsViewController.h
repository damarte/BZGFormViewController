//
//  BZGFormOptionsViewController.h
//  Pods
//
//  Created by David Getapp on 20/01/14.
//
//

#import <UIKit/UIKit.h>

@protocol OptionPickerDelegate <NSObject>
@required
-(void)selectedOption:(NSDictionary *)newOption;
@end

@interface BZGFormOptionsViewController : UITableViewController

@property (strong, nonatomic) NSArray *options;
@property (nonatomic, strong) id<OptionPickerDelegate> delegate;

- (id)initWithOptions:(NSArray *)options;

@end
