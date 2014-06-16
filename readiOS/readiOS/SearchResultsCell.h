//
//  SearchResultsCell.h
//  readiOS
//
//  Created by Ingrid Funie on 20/05/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface SearchResultsCell : UITableViewCell<UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *bookCover;

@property (weak, nonatomic) IBOutlet UILabel *bookTitle;

@property (weak, nonatomic) IBOutlet UILabel *bookAuthor;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) NSArray *pickerViewData;
@property (strong, nonatomic) NSMutableArray *tableNames;


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *authors;
@property (nonatomic, retain) NSString *editor;
@property (nonatomic, retain) NSString *coverLink;
@property (nonatomic) double rating;
@property (nonatomic) NSString *customListTitle;

@property(retain) UIAlertView *av;


- (IBAction)addBookToDatabase:(id)sender;

@end
