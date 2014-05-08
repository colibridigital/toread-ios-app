//
//  BookDetailsViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BookDetailsViewController.h"
#import "BookCollectionViewCell.h"
#import "BooksDatabase.h"
#import <sqlite3.h>

@interface BookDetailsViewController ()

@end

@implementation BookDetailsViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void) initializeViewWithBookDetailsFromDB{
    
    NSLog(@"entering initialisation for details");
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"books.sqlite"];
    sqlite3 *database;
    
    NSLog(@"id %ld, row %li, bookImagesCount %lu", (long)self.cellID, (long)self.indexPath.row, (unsigned long)self.bookImages.count);
    //Open the db. The db was prepared outside the application
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {

        BooksDatabase *bDB = [[BooksDatabase alloc]initWithPrimaryKeyAllDetails:self.cellID database:database table:self.tableName];
        self.bookTitle.text = bDB.title;
        UIImage *bookImage = [UIImage imageWithContentsOfFile:[self.bookImages objectAtIndex:self.indexPath.row]];
        self.bookCover.image = bookImage;
        
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

- (void)scheduleNotification {
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.fireDate = self.datePicker.date;
    //notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:10];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertBody = @"Finish reading book ";
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
    
    ;//should keep this in the database as well
    NSLog(@"Picked the date %@", [dateFormatter stringFromDate:[sender date]]);
    [self.datePicker removeFromSuperview];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.datePicker removeFromSuperview];
}

@end
