//
//  ViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"

@interface MainViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSArray *bookFavoriteImages;
@property (strong, nonatomic) NSArray *bookSuggestedImages;
@property (strong, nonatomic) NSArray *bookUniversityImages;

@property (weak, nonatomic) IBOutlet BookCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *suggestedBooksView;
@property (weak, nonatomic) IBOutlet BookCollectionView *collectionView1;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
- (IBAction)sidebarButtonPressed:(id)sender;

@end
