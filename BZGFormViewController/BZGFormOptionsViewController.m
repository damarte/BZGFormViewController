//
//  BZGFormOptionsViewController.m
//  Pods
//
//  Created by David Getapp on 20/01/14.
//
//

#import "BZGFormOptionsViewController.h"

@interface BZGFormOptionsViewController ()

@end

@implementation BZGFormOptionsViewController

- (id)initWithOptions:(NSArray *)options andSelected:(NSString *)selected
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.options = options;
        self.selected = nil;
        if(selected){
            NSInteger i = 0;
            for (NSDictionary *value in self.options) {
                if([[value objectForKey:@"id"] isEqualToString:selected]){
                    self.selected = [self.options objectAtIndex:i];
                }
                i++;
            }
        }
    }
    
    //Make row selections persist.
    self.clearsSelectionOnViewWillAppear = NO;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.options.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *option = [self.options objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"OptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [option objectForKey:@"name"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selected = [self.options objectAtIndex:indexPath.row];
    
    if([[selected objectForKey:@"id"] isEqualToString:@"0"]){
        selected = nil;
    }
    
    self.selected = selected;
    
    //Notify the delegate if it exists.
    if (_delegate != nil) {
        [_delegate selectedOption:selected];
    }
}

@end
