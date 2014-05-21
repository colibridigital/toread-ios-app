//
//  SearchResultsCell.m
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "SearchResultsCell.h"
#import "CustomBookListView.h"

@implementation SearchResultsCell

- (void)awakeFromNib
{
    // Initialization code
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self initiatePickerViewWithTableNames];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addBookToDatabase:(id)sender {
    
    self.pickerView = [[UIPickerView alloc] init];
    
    [self.pickerView setFrame: CGRectMake(115.0f, 0.0f, 205.0f, 80.0f)];
    
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    
    [self.contentView addSubview:self.pickerView];

    
}

- (void) initiatePickerViewWithTableNames {
    [self.appDelegate getAllDatabaseTableNames];
    self.tableNames = [self.appDelegate.tableNames mutableCopy];
    
    [self.tableNames insertObject:@"" atIndex:0];
    
    NSMutableArray *newTable = [NSMutableArray array];
    
    for (NSString* name in self.tableNames) {
        if ([name rangeOfString:@"suggested"].location != NSNotFound || [name rangeOfString:@"read"].location != NSNotFound || [name rangeOfString:@"favourite"].location != NSNotFound) {
            continue;
        } else{
            [newTable addObject:[[name stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString]];
        }
    }
    
    self.pickerViewData = [newTable mutableCopy];
    
}


// Number of components.
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// Total rows in our component.
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerViewData count];
}

// Display each row's data.
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerViewData objectAtIndex: row];
}

//fix the create new list 
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New List"]) {
        
        NSLog(@"here");
        // CustomBookListView *customBookListView = [[CustomBookListView alloc] initWithNibName:@"CustomBookListView" bundle:nil];
        
        
        //[self.contentView addSubview:customBookListView.view];
        
    } else {
        //add in the specific table in the database the book with the given book details
        
        
        NSLog(@"changed to %@", [self.pickerViewData objectAtIndex:row]);
        
        [self.appDelegate addBookToTheDatabaseBookList:[[self.pickerViewData objectAtIndex:row] lowercaseString] bookTitle:self.title bookAuthors:self.authors publisher:self.editor coverLink:self.coverLink];
        
    }
    
    [self.pickerView removeFromSuperview];
    
}


@end
