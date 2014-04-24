//
//  BookDetailsViewController.m
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BookDetailsViewController.h"

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
    // Do any additional setup after loading the view from its nib.
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
