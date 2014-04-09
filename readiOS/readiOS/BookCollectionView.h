//
//  BookCollectionView.h
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@property (weak, nonatomic) UICollectionView *collView;

@property (strong, nonatomic) NSMutableArray *bookImages;

-(void)registerNibAndCell;

@end
