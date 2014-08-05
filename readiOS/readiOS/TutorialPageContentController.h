//
//  TutorialPageContentController.h
//  readiOS
//
//  Created by Ingrid Funie on 05/08/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialPageContentController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property NSUInteger pageIndex;
@property NSString *imageFile;
@property NSString *descriptionText;

@end
