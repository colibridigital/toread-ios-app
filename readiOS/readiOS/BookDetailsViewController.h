//
//  BookDetailsViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 29/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"
#import "EDStarRating.h"
#import "AppDelegate.h"

@interface BookDetailsViewController : UIViewController<UIGestureRecognizerDelegate, EDStarRatingProtocol, UIAlertViewDelegate>
- (IBAction)dismissDetailsView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthors;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (weak, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NSString *tableName;

@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
@property (weak, nonatomic) IBOutlet UIButton *calendarPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (assign, nonatomic) NSInteger cellID;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (weak, nonatomic) IBOutlet UILabel *starRatingLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) AppDelegate *appDelegate;

@property (nonatomic) int uniqueID;
@property(retain) UIAlertView *av;

- (IBAction)showCalendarPicker:(id)sender;
- (IBAction)pickAction:(id)sender;

@end
