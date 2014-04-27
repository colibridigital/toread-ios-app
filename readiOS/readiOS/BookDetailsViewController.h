//
//  BookDetailsViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"

@interface BookDetailsViewController : UIViewController<UIGestureRecognizerDelegate>
- (IBAction)dismissDetailsView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (weak, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) NSString *tableName;
//this will eventually load the cover
//from the url? 
@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
@property (weak, nonatomic) IBOutlet UIButton *calendarPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) NSMutableArray *bookImages;
@property (assign, nonatomic) NSInteger cellID;

- (IBAction)showCalendarPicker:(id)sender;

@end
