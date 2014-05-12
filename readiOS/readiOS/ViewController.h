//
//  ViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"
#import "AppDelegate.h"


@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate,
UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *customListButton;
- (IBAction)customListSelector:(id)sender;

@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) NSMutableArray *bookMathsImages;
@property (strong, nonatomic) NSMutableArray *bookRandomImages;
@property (strong, nonatomic) NSMutableArray *customCollectionImages;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (strong, nonatomic) NSArray *pickerViewData;
@property (nonatomic) BOOL isEditMode;

@property (weak, nonatomic) IBOutlet BookCollectionView *selectedCollectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *suggestedBooksView;
@property (weak, nonatomic) IBOutlet BookCollectionView *customCollectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *favouriteCollectionView;
@property (weak, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) NSMutableArray *bookImages;
@property (weak, nonatomic) BookCollectionView *collView;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) NSString* tableName;
@property (strong, nonatomic) NSString* collName;
@property (nonatomic) int uniqueID;

- (IBAction)showMenu:(id)sender;
- (void)loadCustomListDatabase;
- (void)loadCustomListDatabaseAndRefreshView;

@end
