//
//  BookDetailsViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BookCollectionViewCell.h"
#import "EDStarRating.h"
#import <sqlite3.h>

@interface BookDetailsViewController ()

@end

@implementation BookDetailsViewController

@synthesize starRating=_starRating;
@synthesize starRatingLabel = _starRatingLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSLog(@"initialize");
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)showWithCustomView:(NSString*)message {
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"show view");
    //i need to pass the table name
    [self initializeViewWithBookDetailsFromDB];
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self initiatePickerViewWithTableNames];
    
    
    _starRating.backgroundColor  = [UIColor blackColor];
    _starRating.starImage = [[UIImage imageNamed:@"star-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.starHighlightedImage = [[UIImage imageNamed:@"star-highlighted-template"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _starRating.maxRating = 5.0;
    _starRating.delegate = self;
    _starRating.horizontalMargin = 15.0;
    _starRating.editable=NO;
    
    _starRating.displayMode=EDStarRatingDisplayHalf;
    [_starRating  setNeedsDisplay];
    _starRating.tintColor = [UIColor yellowColor];
    
    if ([self.tableName isEqual:@"readBooks"]) {
        self.segmentedControl.hidden = YES;
        self.dueDate.hidden = YES;
        self.calendarPicker.hidden = YES;
    }
    
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


- (void) initializeViewWithBookDetailsFromDB{
    
    NSLog(@"entering initialisation for details");
    
    self.appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.uniqueID = [self.appDelegate getNumberOfReadBooksFromDB];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    sqlite3 *database;
    
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
        
        self.bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:self.cellID database:database table:self.tableName];
        self.bookTitle.text = self.bDB.title;
        self.bookAuthors.text = self.bDB.authors;
        
        
        NSLog(@"rating: %f", self.bDB.rating);
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)self.bDB.ID];
        
        NSLog(@"imageNAme %@ from table %@", imageName, self.tableName);
        
        NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
        
        UIImage *bookImage = [UIImage imageWithContentsOfFile:pngFilePath];
        self.bookCover.image = bookImage;
        _starRating.rating= self.bDB.rating;
        
        NSString *ratingString = [NSString stringWithFormat:@"Rating: %.1f", self.bDB.rating];
        
        _starRatingLabel.text = ratingString;
        
        NSLog(@"desc %@", self.bDB.desc);
        
        
        //i can do the same for rating...
        if ([self.bDB.desc isEqual: @""] || self.bDB.desc == NULL) {
            
            if ([self.appDelegate connectedToInternet]) {
                
                RetrieveBooks *retrieveBooks = [[RetrieveBooks alloc] init];
                
                NSData* dataFromURL = [retrieveBooks getDataFromURLAsData:
                                       [NSString stringWithFormat:@"https://www.googleapis.com/books/v1/volumes?q=isbn:%@", self.bDB.isbn]];
                NSArray* results = [retrieveBooks parseJson:[retrieveBooks getJsonFromData:dataFromURL]];
                
                self.bDB.desc = [[[results objectAtIndex:0] objectForKey:@"volumeInfo"] objectForKey:@"description"];
                
                NSLog(@"update the desc in the DB");
                
                const char *sql = [[NSString stringWithFormat:@"update %@ set DESC='%@' where ID = %li", self.tableName, self.bDB.desc, (long)self.bDB.ID] UTF8String];
                NSLog(@"%s",sql);
                sqlite3_stmt *statement;
                
                if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) == SQLITE_OK) {
                    // We step through the results once for each row.
                    NSLog(@"in sql results updating");
                    
                    
                    while (sqlite3_step(statement) == SQLITE_ROW) {
                        
                        NSLog(@"in SQL");
                        int ID = sqlite3_column_int(statement, 0);
                        NSLog(@"ID is %i", ID);
                        
                    }
                    
                    
                    NSLog(@"Updated description in the DB");
                    
                }
                sqlite3_finalize(statement);
                
            }
            
        }
        
        
        self.desc.text = self.bDB.desc;
        
        // finalize the statement
        
        sqlite3_close(database);
    } else {
        //even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open DB with message '%s' .", sqlite3_errmsg(database));
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissDetailsView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)showCalendarPicker:(id)sender {
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    [self.datePicker addTarget:self action:@selector(dueDateChanged:) forControlEvents:UIControlEventValueChanged];
    CGSize pickerSize = [self.datePicker sizeThatFits:CGSizeZero];
    self.datePicker.frame = CGRectMake(0.0, 250, pickerSize.width, 460);
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.datePicker];
}

- (void)showPickerView {
    //show picker view with the database to move the book to
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

- (IBAction)pickAction:(id)sender {
    
    
    NSInteger selectedSegment = self.segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        NSLog(@"first segment selected");
        
        self.av = [[UIAlertView alloc] initWithTitle:@"READ" message:@"Do you really want to mark this as read?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        self.av.tag = 1;
        
        [self.av show];
        
        
    }
    else if (selectedSegment == 1){
        //toggle the correct view to be visible
        
        NSLog(@"second segment selected");
        
        [self showPickerView];
        
    } else {
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Do you really want to delete this?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        self.av.tag = 2;
        
        [self.av show];
        
        NSLog(@"third segment selected");
    }
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Button Index =%ld",(long)buttonIndex);
    
    if (self.av.tag == 1) {
        
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No");
            [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"You have clicked Yes to mark as read from table name : %@", self.tableName);
            NSLog(@"saving png");
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            self.uniqueID  = self.uniqueID + 1;
            NSString *imageName = [NSString stringWithFormat:@"readBooks%ld.png", (long)self.uniqueID];;
            NSString *pngFilePath = [NSString stringWithFormat:@"%@/%@",docDir, imageName];
            NSData *data1 = [NSData dataWithData:UIImagePNGRepresentation(self.bookCover.image)];
            
            [data1 writeToFile:pngFilePath atomically:YES];
            
            NSString *imageN = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)self.cellID];
            
            NSLog(@"imageNAme %@", imageN);
            
            NSString* pngFilePathh = [docDir stringByAppendingPathComponent:imageN];
            NSLog(@"%@", pngFilePathh);
            [self.appDelegate moveBooksToReadInTheDatabase:self.tableName ID:self.cellID indexPath:self.indexPath.row];
            [self.appDelegate deleteBooksToReadFromOriginalTableWithoutDeletingFromTable:self.tableName ID:self.cellID indexPath:self.indexPath.row];
            
            [self removeImage:pngFilePathh];
            
            [self showWithCustomView:@"The book was marked as read"];
            
            [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:1];
            [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:2];
            
        }
    }
    
    if (self.av.tag == 2) {
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked NO");
            [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"You have clicked Yes to delete image %lu at imagePath: from tableName :%@", (long)self.indexPath.row, self.tableName);
            //delete from database
            [self.appDelegate deleteBooksToReadFromOriginalTable:self.tableName ID:self.cellID indexPath:self.indexPath.row];
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)self.cellID];
            
            NSLog(@"imageNAme %@", imageName);
            
            NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
            NSLog(@"%@", pngFilePath);
            [self removeImage:pngFilePath];
            
            [self showWithCustomView:@"The book was deleted"];
            
            [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:0];
            [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:1];
            
        }
        
    }
}

- (void)removeImage:(NSString *)filePath
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:&error];
    if (error){
        NSLog(@"%@", error);
    }
}

- (void)scheduleNotification {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.fireDate = self.datePicker.date;
    //notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    //make this customisable?
    notification.alertBody = [NSString stringWithFormat:@"Finish reading book %@", self.bookTitle.text];
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.alertAction= @"View";
    
    [[UIApplication sharedApplication]scheduleLocalNotification:notification];
}

-(void) dueDateChanged:(UIDatePicker *)sender {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.dueDate.text = [dateFormatter stringFromDate:[self.datePicker date]];
    
    [self scheduleNotification];
    
    ;//add this in the database as well
    NSLog(@"Picked the date %@", [dateFormatter stringFromDate:[sender date]]);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.datePicker removeFromSuperview];
    [self.pickerView removeFromSuperview];
    [self.segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
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
    
    NSLog(@"changed to %@", [self.pickerViewData objectAtIndex:row]);
    
    [self.appDelegate addBookToTheDatabaseBookList:[[self.pickerViewData objectAtIndex:row] lowercaseString] bookTitle:self.bDB.title bookAuthors:self.bDB.authors publisher:self.bDB.editor coverLink:self.bDB.coverLink rating:self.bDB.rating isbn:self.bDB.isbn desc:self.bDB.desc];
    
    [self.appDelegate deleteBooksToReadFromOriginalTable:self.tableName ID:self.cellID indexPath:self.indexPath.row];
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)self.cellID];
    
    NSLog(@"imageNAme %@", imageName);
    
    NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
    NSLog(@"%@", pngFilePath);
    [self removeImage:pngFilePath];
    
    NSLog(@"moving book to the database");
    
    [self showWithCustomView:[NSString stringWithFormat:@"Moved to : %@", [self.pickerViewData objectAtIndex:row]]];
    
    [self.pickerView removeFromSuperview];
    
    [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:0];
    [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:2];
    
}


@end
