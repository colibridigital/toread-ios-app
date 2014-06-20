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
#import "BooksDatabase.h"
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"show view");
    //i need to pass the table name
    [self initializeViewWithBookDetailsFromDB];
    
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
    }
    
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
        
        BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:self.cellID database:database table:self.tableName];
        self.bookTitle.text = bDB.title;
        self.bookAuthors.text = bDB.authors;
        
        NSLog(@"rating: %f", bDB.rating);
        
        NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)bDB.ID];
        
        NSLog(@"imageNAme %@ from table %@", imageName, self.tableName);
        
        NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];
        
        UIImage *bookImage = [UIImage imageWithContentsOfFile:pngFilePath];
        self.bookCover.image = bookImage;
        _starRating.rating= bDB.rating;
        
        NSString *ratingString = [NSString stringWithFormat:@"Rating: %.1f", bDB.rating];
        
        _starRatingLabel.text = ratingString;
        
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

- (IBAction)pickAction:(id)sender {
    
    
    NSInteger selectedSegment = self.segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        //toggle the correct view to be visible
        NSLog(@"first segment selected");
        
        self.av = [[UIAlertView alloc] initWithTitle:@"READ" message:@"Do you really want to mark this as read?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        self.av.tag = 1;
        
        [self.av show];
        
        [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:1];
        [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:2];
        
    }
    else if (selectedSegment == 1){
        //toggle the correct view to be visible
        
        NSLog(@"second segment selected");
    } else {
        
        self.av = [[UIAlertView alloc] initWithTitle:@"Delete" message:@"Do you really want to delete this?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        self.av.tag = 2;
        
        [self.av show];
        
        [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:0];
        [self.segmentedControl setEnabled:FALSE forSegmentAtIndex:1];
        
        NSLog(@"third segment selected");
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"Button Index =%ld",buttonIndex);
    
    if (self.av.tag == 1) {
        
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No");
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

        }
    }
    
    if (self.av.tag == 2) {
        if (buttonIndex == 0)
        {
            NSLog(@"You have clicked No2");
        }
        else if(buttonIndex == 1)
        {
            NSLog(@"You have clicked Yes to delete image %lu at imagePath: from tableName :%@", self.indexPath.row, self.tableName);
            //delete from database
            [self.appDelegate deleteBooksToReadFromOriginalTable:self.tableName ID:self.cellID indexPath:self.indexPath.row];
            
            NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *imageName = [NSString stringWithFormat:@"%@%ld.png",self.tableName,(long)self.cellID];
            
            NSLog(@"imageNAme %@", imageName);
            
            NSString* pngFilePath = [docDir stringByAppendingPathComponent:imageName];            
            NSLog(@"%@", pngFilePath);
            [self removeImage:pngFilePath];
            
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
}

@end
