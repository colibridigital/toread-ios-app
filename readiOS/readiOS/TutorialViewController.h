//
//  TutorialViewController.h
//  readiOS
//
//  Created by Ingrid Funie on 31/07/2014.
//  Copyright (c) 2014 colibri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TutorialPageContentController.h"

@interface TutorialViewController : UIViewController<UIPageViewControllerDataSource>

@property (weak, nonatomic) IBOutlet UIButton *showTutorial;
- (IBAction)showTutorial:(id)sender;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) NSArray *pageDescriptions;

@end
