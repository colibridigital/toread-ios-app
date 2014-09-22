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
#import "BooksDatabase.h"
#import "MBProgressHUD.h"

@interface BookDetailsViewController : UIViewController<UIGestureRecognizerDelegate, EDStarRatingProtocol, UIAlertViewDelegate, MBProgressHUDDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    MBProgressHUD *HUD;
}

- (void)showWithCustomView:(NSString*)message;

- (IBAction)dismissDetailsView:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthors;
@property (weak, nonatomic) IBOutlet UILabel *dueDate;
@property (nonatomic, retain) IBOutlet UITextView *desc;
@property (weak, nonatomic) NSIndexPath *indexPath;
@property (nonatomic) NSString *tableName;

@property (weak, nonatomic) IBOutlet UIImageView *bookCover;
@property (weak, nonatomic) IBOutlet UIButton *calendarPicker;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) NSInteger cellID;
@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
//@property (weak, nonatomic) IBOutlet UILabel *starRatingLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (nonatomic) BooksDatabase *bDB;
@property (retain) RetrieveBooks *retrieveBooks;

@property (nonatomic) int uniqueID;
@property(retain) UIAlertView *av;
@property (nonatomic) NSString *customListTitle;
@property (nonatomic) NSString *moveToListName;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (strong, nonatomic) NSMutableArray *tableNames;

- (IBAction)showCalendarPicker:(id)sender;
- (IBAction)pickAction:(id)sender;
- (IBAction)showBooks:(id)sender;

@end
