//
//  ViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"

@interface ViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *bookFavoriteImages;
@property (strong, nonatomic) NSArray *bookSuggestedImages;
@property (strong, nonatomic) NSArray *bookUniversityImages;

@property (weak, nonatomic) IBOutlet BookCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet BookCollectionView *suggestedBooksView;
@property (weak, nonatomic) IBOutlet BookCollectionView *collectionView1;




@end
