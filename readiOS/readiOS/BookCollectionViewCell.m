//
//  BookCollectionViewCell.m
//  readiOS
//
//  Created by Ingrid Funie on 04/01/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import "BookCollectionViewCell.h"
#import "BookCollectionView.h"


@implementation BookCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        }
    return self;
}

-(id)init {
    
    self = [super init];
    
    UIImage *img = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"default_book_cover" ofType: @"jpg"]];
    
    self.bookImage = [[UIImageView alloc] initWithImage:img];
    
    return self;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
