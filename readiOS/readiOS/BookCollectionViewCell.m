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
        self.pressed = NO;
        }
    return self;
}

- (id) init {
    self = [super init];
    if (self) {
        self.pressed = NO;
    }
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

- (BOOL)deleteButtonPressed {
    return self.pressed;
}

- (IBAction)deleteButtonAction:(id)sender {
    
}

- (void)awakeFromNib
{
   // [self.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

@end
