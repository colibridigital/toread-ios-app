//
//  SearchResultsCell.m
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "SearchResultsCell.h"

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
    
    [self initiatePickerViewWithTableNames];
    
    self.pickerView = [[UIPickerView alloc] init];
    
    [self.pickerView setFrame: CGRectMake(115.0f, 0.0f, 205.0f, 80.0f)];
    
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    
    [self.contentView addSubview:self.pickerView];
    
    
}


- (void)showWithCustomView:(NSString*)message {
	
	HUD = [[MBProgressHUD alloc] initWithView:self.viewForBaselineLayout];
	[self.viewForBaselineLayout addSubview:HUD];
	
	// The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark@2x.png"]];
	
	// Set custom view mode
	HUD.mode = MBProgressHUDModeCustomView;
	
	HUD.delegate = self;
    //modify this according to the needs
	HUD.labelText = message;
	
	[HUD show:YES];
	[HUD hide:YES afterDelay:1.5];
}


- (void) initiatePickerViewWithTableNames {
    [self.appDelegate getAllDatabaseTableNames];
    self.tableNames = [self.appDelegate.tableNames mutableCopy];
    
    NSLog(@"original tableNames data: %lu", (unsigned long)self.appDelegate.tableNames.count);
    
    [self.tableNames insertObject:@"Create New List" atIndex:0];
    
    NSMutableArray *newTable = [NSMutableArray array];
    
    for (NSString* name in self.tableNames) {
        if ([name rangeOfString:@"suggested"].location != NSNotFound || [name rangeOfString:@"read"].location != NSNotFound) {
            continue;
        } else{
            [newTable addObject:[[name stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString]];
        }
    }
    
    self.pickerViewData = [newTable mutableCopy];
    
    NSLog(@"picker view count count %lu", (unsigned long)self.pickerViewData.count);
    
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

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSLog(@"You selected this: %@", [self.pickerViewData objectAtIndex: row]);
    
    if ([[self.pickerViewData objectAtIndex:row] isEqualToString:@"Create New List"]) {
        
        NSLog(@"here");
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Create New List" message:@"Would you like to create a new list called?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        self.av.tag = 1;
        
        [self.av setAlertViewStyle:UIAlertViewStylePlainTextInput];
        
        [self.av show];
        
        
    } else {
        
        self.listToAdd = [self.pickerViewData objectAtIndex:row];
        
        NSString* message = [NSString stringWithFormat:@"Would you like to add a new book to the %@ list?", self.listToAdd];
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Add New Book" message:message delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        self.av.tag = 2;
        
        [self.av show];
        
        
    }
    
    
    
    [self.pickerView removeFromSuperview];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (self.av.tag == 1) {
        
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No");
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"You have clicked Yes with listName %@", [[self.av textFieldAtIndex:0] text]);
            
            self.customListTitle = [[self.av textFieldAtIndex:0] text];
            NSString* listTitle = [self.customListTitle stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            NSLog(@"new list title: %@", listTitle);
            [self.appDelegate createNewCustomListInTheDatabase:listTitle];
            [self.appDelegate addBookToTheDatabaseBookList:[listTitle lowercaseString] bookTitle:self.title bookAuthors:self.authors publisher:self.editor coverLink:self.coverLink rating:self.rating isbn:self.isbn desc:self.desc];
            
            //save the cover here
            
            
            int ID = [self.appDelegate getNumberOfBooksFromDB:[listTitle lowercaseString]];
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *imageName1 = [NSString stringWithFormat:@"%@Books%ld.png",[listTitle lowercaseString],(long)ID];
            NSString* pngFilePath1 = [NSString stringWithFormat:@"%@/%@",docDir, imageName1];
            
            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(self.bookCover.image)];
            
            if (data1 != nil) {
                
                [data1 writeToFile:pngFilePath1 atomically:YES];
                
            } else {
                NSLog(@"book cover object is nill");
            }
            
            NSLog(@"new image name: %@ at path %@", imageName1, pngFilePath1);
            
            [self showWithCustomView:[NSString stringWithFormat:@"Added to : %@", self.customListTitle]];
            
        }
    } else if (self. av.tag == 2) {
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No");
        }
        else if(buttonIndex == 1)
        {
            
            NSLog(@"changed to %@", self.listToAdd);
            
            [self.appDelegate addBookToTheDatabaseBookList:[self.listToAdd lowercaseString] bookTitle:self.title bookAuthors:self.authors publisher:self.editor coverLink:self.coverLink rating:self.rating isbn:self.isbn desc:self.desc];
            
            NSLog(@"adding book to the database");
            
            //save cover here
            
            int ID = [self.appDelegate getNumberOfBooksFromDB:[self.listToAdd lowercaseString]];
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            NSString *imageName1 = [NSString stringWithFormat:@"%@Books%ld.png",[self.listToAdd lowercaseString],(long)ID];
            NSString* pngFilePath1 = [NSString stringWithFormat:@"%@/%@",docDir, imageName1];
            
            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(self.bookCover.image)];
            
            if (data1 != nil) {
                
                [data1 writeToFile:pngFilePath1 atomically:YES];
                
            } else {
                NSLog(@"book cover object is nill");
            }
            
            NSLog(@"new image name: %@ at path %@", imageName1, pngFilePath1);
            
            
            [self showWithCustomView:[NSString stringWithFormat:@"Added to : %@", self.listToAdd]];
        }
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.pickerView removeFromSuperview];

    [self.searchBar resignFirstResponder];
    
}




@end
