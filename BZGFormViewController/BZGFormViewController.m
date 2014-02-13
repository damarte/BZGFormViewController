//
//  BZGFormViewController.m
//
//  https://github.com/benzguo/BZGFormViewController
//

#import "BZGFormViewController.h"
#import "BZGFormFieldCell.h"
#import "BZGFormSelectCell.h"
#import "BZGFormTextCell.h"
#import "BZGFormInfoCell.h"
#import "Constants.h"

@interface BZGFormViewController ()

@end

@implementation BZGFormViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self configureTableView];
    }
    return self;
}

- (void)configureTableView
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = BZG_TABLEVIEW_BACKGROUND_COLOR;
}

#pragma mark - Showing/hiding info cells

- (BZGFormInfoCell *)infoCellBelowFormFieldCell:(BZGFormFieldCell *)fieldCell
{
    NSIndexPath *cellIndex = nil;
    for(NSArray *section in self.formFieldCells){
        cellIndex = [NSIndexPath indexPathForRow:[section indexOfObject:fieldCell] inSection:[self.formFieldCells indexOfObject:section]];
        if([section indexOfObject:fieldCell] != NSNotFound){
            break;
        }
    }
    
    if (cellIndex.row == NSNotFound) return nil;
    if (cellIndex.row + 1 >= [(NSArray *)self.formFieldCells[cellIndex.section] count]) return nil;

    UITableViewCell *cellBelow = self.formFieldCells[cellIndex.section][cellIndex.row + 1];
    if ([cellBelow isKindOfClass:[BZGFormInfoCell class]]) {
        return (BZGFormInfoCell *)cellBelow;
    }

    return nil;
}

- (void)showInfoCellBelowFormFieldCell:(BZGFormFieldCell *)fieldCell
{
    NSIndexPath *cellIndex = nil;
    for(NSArray *section in self.formFieldCells){
        cellIndex = [NSIndexPath indexPathForRow:[section indexOfObject:fieldCell] inSection:[self.formFieldCells indexOfObject:section]];
        if([section indexOfObject:fieldCell] != NSNotFound){
            break;
        }
    }
    
    if (cellIndex.row == NSNotFound) return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex.row+1
                                                inSection:cellIndex.section];

    // if an info cell is already showing, do nothing
    BZGFormInfoCell *infoCell = [self infoCellBelowFormFieldCell:fieldCell];
    if (infoCell) return;

    // otherwise, add the field cell's info cell to the table view
    [self.formFieldCells[cellIndex.section] insertObject:fieldCell.infoCell atIndex:cellIndex.row+1];
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)removeInfoCellBelowFormFieldCell:(BZGFormFieldCell *)fieldCell
{
    NSIndexPath *cellIndex = nil;
    for(NSArray *section in self.formFieldCells){
        cellIndex = [NSIndexPath indexPathForRow:[section indexOfObject:fieldCell] inSection:[self.formFieldCells indexOfObject:section]];
        if([section indexOfObject:fieldCell] != NSNotFound){
            break;
        }
    }
    
    if (cellIndex.row == NSNotFound) return;

    // if no info cell is showing, do nothing
    BZGFormInfoCell *infoCell = [self infoCellBelowFormFieldCell:fieldCell];
    if (!infoCell) return;

    // otherwise, remove it
    [self.formFieldCells[cellIndex.section] removeObjectAtIndex:cellIndex.row+1];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cellIndex.row+1
                                                inSection:cellIndex.section];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)updateInfoCellBelowFormFieldCell:(BZGFormFieldCell *)fieldCell
{
    if (fieldCell.shouldShowInfoCell && !fieldCell.textField.editing) {
        [self showInfoCellBelowFormFieldCell:fieldCell];
    } else {
        [self removeInfoCellBelowFormFieldCell:fieldCell];
    }
}

#pragma mark - Finding cells

- (BZGFormFieldCell *)firstInvalidFormFieldCell
{
    for(NSArray *section in self.formFieldCells) {
        for (UITableViewCell *cell in section) {
            if ([cell isKindOfClass:[BZGFormFieldCell class]]) {
                if (((BZGFormFieldCell *)cell).validationState == BZGValidationStateInvalid) {
                    return (BZGFormFieldCell *)cell;
                }
            }
        }
    }
    return nil;
}

- (BZGFormFieldCell *)nextFormFieldCell:(BZGFormFieldCell *)fieldCell
{
    NSUInteger cellIndex = [self.formFieldCells indexOfObject:fieldCell];
    if (cellIndex == NSNotFound) return nil;

    for (NSUInteger i = cellIndex + 1; i < self.formFieldCells.count; ++i) {
        UITableViewCell *cell = self.formFieldCells[i];
        if ([cell isKindOfClass:[BZGFormFieldCell class]]) {
            return (BZGFormFieldCell *)cell;
        }
    }
    return nil;
}

- (void)submit
{

}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.formFieldCells) {
        return self.formFieldCells.count;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.formFieldCells) {
        return [(NSArray *)[self.formFieldCells objectAtIndex:section] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.formFieldCells) {
        return [self.formFieldCells[indexPath.section] objectAtIndex:indexPath.row];
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.formFieldCells) {
        UITableViewCell *cell = [self.formFieldCells[indexPath.section] objectAtIndex:indexPath.row];
        return cell.frame.size.height;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.formSectionsTitle && self.formSectionsTitle.count > section) {
        return [self.formSectionsTitle objectAtIndex:section];
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell isKindOfClass:[BZGFormFieldCell class]]){
        [((BZGFormFieldCell *)cell) redraw];
    }
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == self.formFieldCells.count && indexPath.row == 0){
        BOOL valid = YES;
        
        for(NSArray *section in self.formFieldCells) {
            for (UITableViewCell *cell in section) {
                if ([cell isKindOfClass:[BZGFormFieldCell class]]) {
                    if (((BZGFormFieldCell *)cell).validationState != BZGValidationStateValid) {
                        valid = NO;
                    }
                }
            }
        }
        
        if(valid){
            [self submit];
        }
    }
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    BZGFormFieldCell *cell = [BZGFormFieldCell parentCellForTextField:textField];
    if (!cell) {
        return;
    }
    if (cell.didBeginEditingBlock) {
        cell.didBeginEditingBlock(cell, textField.text);
    }
    [self updateInfoCellBelowFormFieldCell:cell];

    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    BZGFormFieldCell *cell = [BZGFormFieldCell parentCellForTextField:textField];
    if (!cell) {
        return YES;
    }

    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (cell.shouldChangeTextBlock) {
        shouldChange = cell.shouldChangeTextBlock(cell, newText);
    }

    [self updateInfoCellBelowFormFieldCell:cell];
    return shouldChange;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    BZGFormFieldCell *cell = [BZGFormFieldCell parentCellForTextField:textField];
    if (!cell) {
        return;
    }
    if (cell.didEndEditingBlock) {
        cell.didEndEditingBlock(cell, textField.text);
    }

    [self updateInfoCellBelowFormFieldCell:cell];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL shouldReturn = YES;
    BZGFormFieldCell *cell = [BZGFormFieldCell parentCellForTextField:textField];
    if (!cell) {
        return YES;
    }

    if (cell.shouldReturnBlock) {
        shouldReturn = cell.shouldReturnBlock(cell, textField.text);
    }

    BZGFormFieldCell *nextCell = [self nextFormFieldCell:cell];
    if (!nextCell) {
        [cell.textField resignFirstResponder];
    }
    else {
        [nextCell.textField becomeFirstResponder];
    }

    [self updateInfoCellBelowFormFieldCell:cell];
    return shouldReturn;
}

#pragma mark - SelectCellDelegate

-(void)selectedOption:(NSDictionary *)newOption withCell:(BZGFormSelectCell *)cell
{
    if (cell.shouldChangeBlock) {
        cell.shouldChangeBlock(cell, newOption);
    }
    
    [self updateInfoCellBelowFormFieldCell:cell];
}


@end
