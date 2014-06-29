//
//  BarcodeScannerResultDetails.h
//  readiOS
//
//  Created by Ingrid Funie on 26/06/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

@interface BarcodeScannerResultDetails : UIViewController<UIGestureRecognizerDelegate, EDStarRatingProtocol, UIAlertViewDelegate, MBProgressHUDDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    MBProgressHUD *HUD;
}


- (void)showWithCustomView:(NSString*)message;

@property (strong, nonatomic) NSArray *scanResult;

@property (weak, nonatomic) IBOutlet UILabel *bookTitle;
@property (weak, nonatomic) IBOutlet UILabel *bookAuthors;
@property (nonatomic) NSString *tableName;
@property (nonatomic) NSString *editor;
@property (nonatomic) NSString *coverLink;
@property (nonatomic) NSString *isbn;

@property (weak, nonatomic) IBOutlet UIImageView *bookCover;

@property (weak, nonatomic) IBOutlet EDStarRating *starRating;
@property (nonatomic) double rating;
@property (weak, nonatomic) IBOutlet UILabel *starRatingLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (strong, nonatomic) NSMutableArray *tableNames;

- (IBAction)pickAction:(id)sender;

@end
