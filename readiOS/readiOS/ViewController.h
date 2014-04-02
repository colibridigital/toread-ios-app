//
//  ViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate,
UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *customListButton;
- (IBAction)customListSelector:(id)sender;

@property (strong, nonatomic) UIPickerView *pickerView;

@property (strong, nonatomic) NSArray *bookFavoriteImages;
@property (strong, nonatomic) NSArray *bookSuggestedImages;
@property (strong, nonatomic) NSArray *bookUniversityImages;
@property (strong, nonatomic) NSArray *bookMathsImages;
@property (strong, nonatomic) NSArray *bookRandomImages;
@property (strong, nonatomic) NSArray *customCollectionImages;

@property (strong, nonatomic) NSArray *pickerViewData;

@property (weak, nonatomic) IBOutlet BookCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *suggestedBooksView;
@property (weak, nonatomic) IBOutlet BookCollectionView *customCollectionView;




@end
