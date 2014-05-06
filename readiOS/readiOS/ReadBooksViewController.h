//
//  ReadBooksViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 29/04/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookCollectionView.h"
#import "AppDelegate.h"
#import <sqlite3.h>

@interface ReadBooksViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate> {
    sqlite3 *database;
}
@property (weak, nonatomic) IBOutlet BookCollectionView *collectionView;
@property (weak, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) NSMutableArray *booksImages;

@property (strong, nonatomic) NSMutableArray *readBooks;

@end
