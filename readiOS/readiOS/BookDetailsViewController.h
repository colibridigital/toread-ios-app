//
//  BookDetailsViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookDetailsViewController : UIViewController<UIGestureRecognizerDelegate>
- (IBAction)dismissDetailsView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
//this will eventually load the cover
//from the url? 
@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
@property (weak, nonatomic) IBOutlet UIButton *calendarPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
- (IBAction)showCalendarPicker:(id)sender;

@end
