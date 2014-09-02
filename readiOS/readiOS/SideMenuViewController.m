//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "ReadBooksViewController.h"
#import "ReadingListManager.h"

@implementation SideMenuViewController

#pragma mark -
#pragma mark - UITableViewDataSource

-(void)viewDidLoad {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.tableView addGestureRecognizer:tap];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSIndexPath *firstRowPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if ([indexPath isEqual:firstRowPath]) {
        cell.textLabel.text = [NSString stringWithFormat:@"What I've Read"];
    } else if ([indexPath isEqual:[NSIndexPath indexPathForRow:0 inSection:1]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"All My Reading Lists"];
    }
      /* else if ([indexPath isEqual:[NSIndexPath indexPathForItem:0 inSection:1]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"My Account"];
    }*/ else if ([indexPath isEqual:[NSIndexPath indexPathForItem:0 inSection:2]]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Send List via Email"];
    } /*else if ([indexPath isEqual:[NSIndexPath indexPathForItem:0 inSection:2]]){
        cell.textLabel.text = [NSString stringWithFormat:@"Refresh Reading Lists"];
    }*/
    
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor grayColor];
    
    return cell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([indexPath  isEqual:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        NSLog(@"in read books selection");
        ReadBooksViewController *bookListView = [[ReadBooksViewController alloc] initWithNibName:@"ReadBooksViewController" bundle:nil];
        
        self.navigationController = self.menuContainerViewController.centerViewController;
        NSLog(@"will show view");
        [self.navigationController presentViewController:bookListView animated:NO completion:nil];
        
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    } else if ([indexPath  isEqual:[NSIndexPath indexPathForRow:0 inSection:1]]) {
        NSLog(@"in What I want to read");
        
        ReadingListManager *readingListManager = [[ReadingListManager alloc] initWithNibName:@"ReadingListManager" bundle:nil];
        
        self.navigationController = self.menuContainerViewController.centerViewController;
        
        [self.navigationController presentViewController:readingListManager animated:NO completion:nil];
        
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
        
    }
       else if ([indexPath isEqual:[NSIndexPath indexPathForItem:0 inSection:2]]) {
        
        self.emailManager =[[EmailManager alloc] init];
        
        self.navigationController = self.menuContainerViewController.centerViewController;
        
        NSLog(@"will show view");
        
        self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        [self initiatePickerViewWithTableNames];
        
        [self showPickerView]; 
        
    } /*else {
        
        UIViewController *demoController = [[UIViewController alloc] init];
        demoController.title = [NSString stringWithFormat:@"Demo #%ld-%ld", (long)indexPath.section, (long)indexPath.row];
        
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:demoController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }*/
}

- (void) initiatePickerViewWithTableNames {
    [self.appDelegate getAllDatabaseTableNames];
    self.tableNames = [self.appDelegate.tableNames mutableCopy];
    
    [self.tableNames insertObject:@"" atIndex:0];
    
    NSMutableArray *newTable = [NSMutableArray array];
    
    for (NSString* name in self.tableNames) {
        if ([name rangeOfString:@"suggested"].location != NSNotFound || [name rangeOfString:@"read"].location != NSNotFound) {
            continue;
        } else{
            [newTable addObject:[[name stringByReplacingOccurrencesOfString:@"Books" withString:@""] capitalizedString]];
        }
    }
    
    self.pickerViewData = [newTable mutableCopy];
    
}


- (void) showPickerView {
    
    
    self.pickerView = [[UIPickerView alloc] init];
    
    // Calculate the screen's width.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float pickerWidth = screenWidth * 3 / 4;
    
    // Calculate the starting x coordinate.
    float xPoint = screenWidth / 2 - pickerWidth / 2;
    
    // Set the picker's frame. We set the y coordinate to 50px.
    [self.pickerView setFrame: CGRectMake(xPoint, 245.0f, pickerWidth, 130.0f)];
    
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    self.pickerView.showsSelectionIndicator = YES;
    self.pickerView.backgroundColor = [UIColor whiteColor];
    
    [self.pickerView selectRow:0 inComponent:0 animated:NO];
    
    [self.view addSubview:self.pickerView];
    
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
    
    
    self.listTitle = [self.pickerViewData objectAtIndex:row];
    
    NSString *listName = [NSString stringWithFormat:@"%@Books", [self.listTitle lowercaseString]];
    
    if (![self.listTitle isEqualToString:@""]) {
        
        [self.emailManager saveDetailsFromDatabaseList:listName];
        
        MFMailComposeViewController *mailComposer = [self.emailManager displayComposerSheet];
        
        mailComposer.mailComposeDelegate = self;
        
        [self.navigationController presentViewController:mailComposer animated:NO completion:nil];
    }
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
    [self.pickerView removeFromSuperview];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSLog(@"what is the result");
    
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];
    
    if (indexPath) { //we are in a tableview cell, let the gesture be handled by the view
        recognizer.cancelsTouchesInView = NO;
    } else { // anywhere else, do what is needed for your case
        [self.pickerView removeFromSuperview];
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
}


@end
